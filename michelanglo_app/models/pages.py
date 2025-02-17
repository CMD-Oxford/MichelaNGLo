import os, re, pickle, datetime
import base64
from Crypto.Cipher import AES
from Crypto.Hash import SHA256
from Crypto import Random

import bleach
bleach.sanitizer.ALLOWED_TAGS.extend(['span', 'div', 'img', 'h1', 'h2','h3','h4','h5','p', 'pre', 'code'])
bleach.sanitizer.ALLOWED_ATTRIBUTES['*'] = ['class','id']
bleach.sanitizer.ALLOWED_ATTRIBUTES['span'] = lambda tag, name, value: True if name in ('class','id') or 'data-' in name else False
bleach.sanitizer.ALLOWED_ATTRIBUTES['img'] = lambda tag, name, value: True if name in ('class','id','height', 'width', 'src') and 'javascript' not in value.lower() else False

##################### Page
# The reason this is not a full DB is because
# * the PDB files can get massive

#import bcrypt
from sqlalchemy import (
    Column,
    Integer,
    Text,
    DateTime,
    Boolean
)

from .meta import Base


class Page(Base):
    """ The SQLAlchemy declarative model class for a Page object.
        This is just to speed up things. The actual data is in user-data as a pickle!
        CREATE TABLE pages (
        index SERIAL PRIMARY KEY NOT NULL,
        uuid TEXT NOT NULL UNIQUE,
        title TEXT,
        existant BOOL,
        edited BOOL,
        encrypted BOOL,
        timestamp TIMESTAMP NOT NULL);

        privacy ought to be an enum... private | public | published | sgc | pinned
        any change to it need to be changed in gallery.mako

        """
    __tablename__ = 'pages'
    id = Column(Integer, primary_key=True)
    identifier = Column(Text, nullable=False, unique=True)
    title = Column(Text, default='')
    existant = Column(Boolean, default=True)  # existent is the correct spelling. exists is a key word in SQLite
    edited = Column(Boolean, default=False)
    encrypted = Column(Boolean, default=False)
    timestamp = Column(DateTime, nullable=False) #, default=datetime.datetime.utcnow)
    protected = Column(Boolean, default=False)
    privacy = Column(Text, default='private') #private | public | published | sgc | pinned
    settings = None  #watchout this ought to be a dict, but dict is mutable.
    key = None
    # paths changed from michelanglo_app/user-data and michelanglo_app/user-data-thumb
    data_folder = 'user_data'  # class attribute changed in .model.__init__ config.
    unencrypted_path = property(lambda self: os.path.join(self.data_folder, 'pages', self.identifier + '.p'))
    encrypted_path = property(lambda self: os.path.join(self.data_folder, 'pages', self.identifier + '.ep'))
    thumb_path = property(lambda self: os.path.join(self.data_folder, 'thumb', self.identifier + '.png'))
    path = property(lambda self: self.encrypted_path if self.encrypted is True else self.unencrypted_path)

    def __init__(self, identifier, key=None):
        self.identifier = identifier.replace('\\','/').replace('*','').split('/')[-1]
        if key:
            self.encrypted = True
            self.key = key.encode('utf-8')  # this does not get committed to the db. Promise.
        else:
            self.encrypted = False
            self.key = None
        self.settings = {}

    @property
    def age(self) -> int:
        """
        Age is an integer (days) since last viewed!
        """
        return (datetime.datetime.now() - self.timestamp).days

    @property
    def safe_age(self):
        """
        Age since last viewed is for deletion. Some pages should not be deleted. so return a nan.
        """
        # how long until deletion
        if not self.existant:
            return float('nan')
        elif self.protected:
            return float('nan')
        elif self.privacy != 'private':
            return float('nan')
        elif self.edited:
            return self.age
        else:
            return self.age

    def fill_defaults(self, settings=None):
        if settings is None:
            settings = self.settings
        for fun, keys in ((list, ('editors', 'visitors', 'authors')),
                          (bool, (
                          'image', 'uniform_non_carbon', 'verbose', 'validation', 'save', 'public', 'confidential',
                          'encryption', 'model')),
                          (str, ('viewport', 'stick', 'backgroundcolor', 'loadfun', 'proteinJSON', 'pdb', 'description',
                                 'descr_mdowned','title', 'data_other')),
                          (list, ('revisions',))):
            for key in keys:
                if key not in settings:
                    settings[key] = fun()
        return self

    def load(self):
        if self.existant:
            if self.encrypted:
                if self.key:
                    with open(self.path, 'rb') as fh:
                        cryptic = fh.read()
                        decryptic = self._decrypt(cryptic)
                        self.settings = pickle.loads(decryptic)
                else:
                    raise ValueError('No key provided.')
            else:
                with open(self.path, 'rb') as fh:
                    self.settings = pickle.load(fh)
        elif os.path.exists(self.path):
            raise FileExistsError(f'File {self.identifier} exists but is not in the DB!')
        else:
            raise FileNotFoundError(f'File {self.identifier} ought to exist?')
        self.fill_defaults()
        # it was accessed.
        self.timestamp = datetime.datetime.utcnow()
        return self

    def save(self, settings=None):
        ## sort things out
        if settings is None:
            settings = {}
        if self.settings is None: # technically impossible
            self.settings = {}
        ## merge.
        settings = {**self.settings, **settings}
        if not settings:  ## last ditch.
            settings = self.load().settings
        if 'description' not in settings:
            settings['description'] = 'Warning: Description lost??!'
        if 'title' not in settings:
            settings['title'] = 'Warning: Your title has been somehow lost'
        self.fill_defaults(settings)
        # metadata
        settings['date'] = str(datetime.datetime.now())  # redundant
        settings['page'] = self.identifier
        if self.encrypted:
            settings['key'] = self.key # is this wise? It will be encrypted in. So should be. This is so it the mako template requests are good.
        ## write
        with open(self.path, 'wb') as fh:
            if not self.encrypted:
                pickle.dump(settings, fh)
            elif not self.key:
                raise ValueError(f'Impossible. No key provided in saving {self.identifier}...')
            else:
                uncryptic = pickle.dumps(settings)
                cryptic = self._encrypt(uncryptic)
                fh.write(cryptic)
        self.existant = True
        self.title = settings['title'] ## keep synched!
        self.timestamp = datetime.datetime.utcnow()
        return self

    #https://stackoverflow.com/questions/42568262/how-to-encrypt-text-with-a-password-in-python
    def _encrypt(self, source, encode=False):
        key = SHA256.new(self.key).digest()  # use SHA-256 over our key to get a proper-sized AES key
        IV = Random.new().read(AES.block_size)  # generate IV
        encryptor = AES.new(key, AES.MODE_CBC, IV)
        padding = AES.block_size - len(source) % AES.block_size  # calculate needed padding
        source += bytes([padding]) * padding # pad
        data = IV + encryptor.encrypt(source)  # store the IV at the beginning and encrypt
        return base64.b64encode(data).decode("latin-1") if encode else data

    def _decrypt(self, source, decode=False):
        if decode:
            source = base64.b64decode(source.encode("latin-1"))
        key = SHA256.new(self.key).digest()  # use SHA-256 over our key to get a proper-sized AES key
        IV = source[:AES.block_size]  # extract the IV from the beginning
        decryptor = AES.new(key, AES.MODE_CBC, IV)
        data = decryptor.decrypt(source[AES.block_size:])  # decrypt
        padding = data[-1]  # pick the padding value from the end; Python 2.x: ord(data[-1])
        if data[-padding:] != bytes([padding]) * padding:  # Python 2.x: chr(padding) * padding
            raise ValueError("Invalid padding...")
        return data[:-padding]  # remove the padding

    def delete(self):
        if os.path.exists(self.path):
            os.remove(self.path)
        else:
            pass
        self.existant = False
        # print('DEBUG.... DELETION OF A NON EXISTANT PAGE IS IMPOSSIBLE')
        return self

    def is_public(self):
        if self.privacy == 'private':
            return False
        elif self.privacy is False:
            ## This is a legacy page!
            self.privacy = 'private'
            return False
        else:
            return True

    @staticmethod
    def sanitise_URL(page):
        return page.replace('\\', '/').replace('*', '').split('/')[-1]

    @staticmethod
    def sanitise_HTML(code):
        code=bleach.clean(code)
        code=bleach.linkify(code)
        return code

    @staticmethod
    def alt_sanitise_HTML(code):
        ### this is more liberal and does not require tags. It is used only by data_other
        def substitute(code, pattern, message):
            code = re.sub(f'<[^>\w]*?\W{pattern}[\s\S]*?>', message, code, re.IGNORECASE | re.MULTILINE | re.DOTALL)
            code = re.sub(f'<{pattern}[\s\S]*?>', message, code, re.IGNORECASE | re.MULTILINE | re.DOTALL)
            pseudo = re.sub('''(<[^>\w]*?)['`"][\s\S]*?['`"]''', r'\1', code, re.IGNORECASE | re.MULTILINE | re.DOTALL)
            if re.search(f'<[^>]*?\W{pattern}[\s\S]*?>', pseudo) or re.search(f'<{pattern}[\s\S]*?>', pseudo):  # go extreme.
                code = re.sub(pattern, message, code, re.IGNORECASE | re.MULTILINE | re.DOTALL)
            return code

        code = re.sub('<!--*?-->', 'COMMENT REMOVED', code)
        for character in ('\t', '#x09;', '&#x0A;', '&#x0D;', '\0'):
            code = code.replace(character, ' ' * 4)
        code = code.replace(character, ' ' * 4)
        for tag in ('script', 'iframe', 'object', ' link', 'style', 'meta', 'frame', 'embed'):
            code = substitute(code, tag, tag.upper() + ' BLOCKED')
        for attr in ('javascript', 'vbscript', 'livescript', 'xss', 'seekSegmentTime', '&{', 'expression'):
            code = substitute(code, attr, attr.upper() + ' BLOCKED')
        code = substitute(code, 'on\w+', 'ON-EVENT BLOCKED')
        for letter in range(65, 123):
            code = substitute(code, f'&#0*{letter};', 'HEX ENCODED LETTER BLOCKED')
            code = substitute(code, f'&#x0*{letter:02X};', 'HEX ENCODED LETTER BLOCKED')
        return code

    def commit(self, request):
        cls = self.__class__
        request.dbsession.add(self)

    def __str__(self):
        return str(self.identifier)

    @classmethod
    def select(cls, session, identifier):
        #get the DB version...
        self = session.query(cls).filter(cls.identifier == identifier).first()
        return self

    @classmethod
    def select_list(cls, session, pages):
        """returns the list of existing pages as Page objects from the db"""
        query = session.query(cls).filter(cls.identifier.in_(pages)).all()
        return [page for page in query if page.existant]
