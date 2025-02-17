//<%text>
// same as venus route!

const vbtn = $('#venus_calc');
mutation.keyup(e => {
    if ($(e.target).val().search(/\d+/) !== -1 && uniprotValue !== 'ERROR') {
        vbtn.show();
        $('#error_mutation').hide();
        $(e.target).removeClass('is-invalid');
        if (event.keyCode === 13) vbtn.click();
    } else {
        vbtn.hide();
    }
});

// different
// not... class MultiVenus extends Venus {....

class MultiVenus {
    // a new mv instance is made each time analyse is clicked.
    constructor() {
        //this.protein = null; // to be filled with obj from ajax
        this.last_clicked_prolink = null; //to be filled by clicking.
        this.uniprot = window.uniprotValue;
        this.taxid = window.taxidValue;
        // assess variants.
        const mv = this.getMutationsValidity();
        if (Object.values(mv).every(v => v)) {
            // all valid mutations.
            this.mutations = Object.keys(mv);
        } else { //invalid mutation
            Object.keys(mv).filter(k => !mv[k]).map(k => {
                ops.addToast('dodgymutant' + k, '<i class="far fa-alien-monster"></i> Invalid mutation format for ' + k,
                    'VENUS analyses protein mutations only. The mutation needs to be in the format A123E or Ala123Glu, with or without "p." prefix. Case insensitive.', 'bg-warning');
                $('#venus_calc').removeAttr('disabled');
            });
            throw('invalid mutation');
        }

    }

    analyse() {
        return $.post({
            url: "venus_multianalyse", data: {
                uniprot: this.uniprot,
                species: this.taxid,
                mutations: this.mutations.join(' ')
            }
        }).fail(ops.addErrorToast)
            .done(msg => {
                $('#venus_calc').removeAttr('disabled');
                if (msg.error) {
                    $('#error_' + msg.error).show();
                    $('#' + msg.error).addClass('is-invalid');
                    ops.addToast('error', 'Error - ' + msg.error, '<i class="far fa-bug"></i> An issue arose analysing the results.<br/>' + msg.msg, 'bg-warning');
                } else { //status success!
                    $('html, body').animate({scrollTop: $('#results').offset().top}, 2000);
                    $('#results').show(500);
                    //this.protein = msg.protein;
                    this.choices = msg.choices;
                    this.urls = msg.urls;
                    this.fvBlock = msg.fv;
                    //this.addFeatureViewer() is added on protein load.
                    this.addMutationsList();
                    this.addModelList();
                    this.loadFirst();
                }
            });
    }

    //step 0 copied from venus class then modded.
    getMutationsValidity() { // get a obj of key=mut & value=bool
        let mutations = window.mutation.value.replace(/p\./g, '').split(/[^\w*]/).filter(m => m.length !== 0);
        //check the mutation is valid
        //this is a copy paste of the fun from pdb_staging_insert.js
        const aa = {
            'CYS': 'C', 'ASP': 'D', 'SER': 'S', 'GLN': 'Q', 'LYS': 'K',
            'ILE': 'I', 'PRO': 'P', 'THR': 'T', 'PHE': 'F', 'ASN': 'N',
            'GLY': 'G', 'HIS': 'H', 'LEU': 'L', 'ARG': 'R', 'TRP': 'W',
            'ALA': 'A', 'VAL': 'V', 'GLU': 'E', 'TYR': 'Y', 'MET': 'M'
        };
        return Object.fromEntries(mutations.map(
            mutation => {
                let parts = mutation.match(/^(\D{1,3})(\d+)(\D{1,3})$/);
                // ["G10W", "G", "10", "W", index: 0, input: "G10W", groups: undefined]
                const getMutation = (p) => p.splice(1, 3).join('');
                if (parts === null) return [mutation, false];
                // deal with three letter code.
                if (aa[parts[1]] !== undefined) {
                    parts[1] = aa[parts[1]];
                }
                if (!'ACDEFGHIKLMNPQRSTVWYX'.includes(parts[1])) return [getMutation(parts), false];
                if (aa[parts[3]] !== undefined) {
                    parts[3] = aa[parts[3]]
                }
                if (!'ACDEFGHIKLMNPQRSTVWYX'.includes(parts[1])) return [getMutation(parts), false];
                // it's good
                return [getMutation(parts), true];
            })
        );

    }

    addMutationsList() {
        const inners = this.mutations.map(mutation => `<li class="list-group-item">
                                                            <div class="row">
                                                                <div class="col-md-4">
                                                                    <b>${mutation}</b>
                                                                </div>
                                                                <div class="col-md-4">
                                                                    <span class="prolink" data-target="viewport"
                                                                        data-focus="residue" data-selection="${mutation.slice(1, -1)}">show wt</span>
                                                                </div>
                                                                <div class="col-md-4">
                                                                    <a class="btn btn-outline-info" href="/venus?uniprot=${this.uniprot}&species=${this.taxid}&mutation=${mutation}" target="_blank"><i class="far fa-vials"></i> Analyse in VENUS</a>
                                                                </div>
                                                            </div>
                                                        </li>`);
        $('#result_mutation_list').html(inners.join('\n'));
        $('#result_mutation_list .prolink').protein();
    }

    addModelList() {
        const inners = Object.keys(this.choices).map(k => {
            const valids = this.choices[k].join(', ') || 'none';
            let selections = this.mutations.map(mutation => mutation.slice(1, -1)).join(' or ');
            if (this.choices[k].length === 0) {
                selections = 'ligand'; // not really a valid option!
            }
            let model, name, chain;
            if (k.length === 6) {
                name = `PDB:${k}`;
                chain = k.slice(-1,);
                model = k.slice(0, -2);
                selections = `(${selections}) and :${chain}`;
            } else {
                name = `SWISSMODEL:${k}`;
                model = k;
                chain = 'A';
            }
            return `<button type="button" class="list-group-item list-group-item-action"
                                    data-target="viewport"
                                    data-focus="residue" data-selection="${selections}"
                                    data-load="${model}"
                                    data-chain="${chain}"
                                    data-name="${k}"
                                >
                                    ${name}: ${valids}
                                </button>`; //data-chain and data-name are for this only!!
        });
        $('#results_mutalist').html(inners.join('\n'));
        $('#results_mutalist button').click(event => {
            const prolink = $(event.target);
            $('#results_mutalist .active').removeClass('active');
            prolink.addClass('active');
            if (prolink.data('name').length === 6) {
                // PDB. pass
            } else {
                // swissmodel
                if (window.myData === undefined) NGL.specialOps.postInitialise('viewport');
                const name = prolink.data('name'); //same as data-load for swissmodel!
                const url = window.multivenus.urls[name];
                window.myData.proteins.push({value: url, type: 'url', name: name});
            }
            NGL.specialOps.prolink(event.target);
            window.multivenus.last_clicked_prolink = event.target;
            window.multivenus.addFeatureViewer.call(window.multivenus);
            myData.currentChain = prolink.data('chain'); //nonstandard!
        })
        setTimeout(() => {
            NGL.specialOps._preventScroll('viewport');
            NGL.specialOps.enableClickToShow('viewport');
        }, 1000);
        // Disabled for now as AF2 does all!
        // $('#results_card').append(`<div class="p-2">
        // <button type="button" class="btn btn-outline-warning w-100" data-toggle="modal" data-target="#createCombo">
        //     <i class="far fa-dumpster-fire"></i> Merge structures</button>
        // </div>`);

    }

    addFeatureViewer() {
        $('#fv').html('');
        eval(this.fvBlock);
        d3.selectAll('.axis text').style("font-size", "0.6em");
        //new MutantLocation(this.position);
        this.mutations.forEach(mutation => ft.addMutation(parseInt(mutation.slice(1, -1))));
        UniprotFV.empower();
    }

    loadFirst() {
        const covered = Object.values(this.choices).reduce((acc, v) => {
                                                                            v.forEach(vv => acc.add(vv));
                                                                            return acc
                                                                        },
                                                            new Set());
        let msgs = [];
        const notInferior = `<b>NB.</b>The lack of a structure spanning a residue does
                                not necessarily mean that the residue is in a less important region.`;
        // No matches.
        if (covered.size === 0) {
            let mainMsg = `There is no available structure that spans the mutations requested (${this.mutations.join(', ')}).`;
            ops.addToast('unavailable', 'No applicable structure', mainMsg, 'bg-warning');
            msgs.push(mainMsg, notInferior);
            $('#result_mutations_text').html(msgs.join('<br/>'));
            //nothing loaded.
            return 0;
        } else { // some matches.
            const first =$('#results_mutalist button').first();
            const firstName = first.data('name');
            // what does the model cover?
            const firstUncovered = this.choices[firstName].filter(v => this.mutations.indexOf(v) === -1);
            if (firstUncovered.length > 0) {
                msgs.push(`The model loaded, ${firstName}, covers ${this.choices[firstName].join(', ')}, 
                                    but not ${firstUncovered.join(', ')}.`, notInferior);
            } else {
                msgs.push(`The model loaded, ${firstName}, covers ${this.choices[firstName].join(', ')}.`);
            }
            // any never covered?
            if (covered.size !== this.mutations.length) {
                msgs.push(`The mutation(s) ${this.mutations.filter(v => !covered.has(v)).join(', ')} are not covered by any model.`);
            }
            msgs.push('For other models see <a href="#results_card">Models section</a>.');
            first.click();
            $('#result_mutations_text').html(msgs.join('<br/>'));
        }
    }
}


vbtn.click(e => {
    if (taxidValue === 'ERROR') {
        $('#error_species').show();
        return 0;
    }
    if (uniprotValue === 'ERROR') {
        $('#error_gene').show();
        return 0;
    }
    if (mutation.val().search(/\d+/) === -1) {
        $('#error_mutation').show();
        return 0;
    }
    $(e.target).attr('disabled', 'disabled');
    try {
        window.multivenus = new MultiVenus();
        window.multivenus.analyse();
    } catch (e) {
        // already dealt with.
        if (e !== 'invalid mutation') throw e;
    }

});

$(window).scroll(() => {
    const card = $('#vieport_side');
    let currentY = $(window).scrollTop();
    let windowH = $(window).innerHeight();
    let cardH = card.height();
    let offsetY = card.offset().top - parseInt(card.css('top')) - 4;
    const rcard = $('#results_card');
    let maxY = rcard.offset().top + rcard.height();
    //console.log(`currentY ${currentY}, windowH ${windowH}, cardH ${cardH}, offsetY ${offsetY}, maxY ${maxY}`)
    let position = 0;
    // the top is getting cut off:
    if ((currentY > offsetY) && (currentY + windowH > offsetY + cardH)) {
        // new position, without cutting off the bottom.
        position = cardH > windowH ? currentY - offsetY - (cardH - windowH) : currentY - offsetY;
        if (cardH + currentY > maxY) {
            return 0; //no change. i.e. position = card.css('top')
        }
    }
    card.css('top', position);
    //console.log(`scrolltop: ${currentY} win height ${windowY} off: ${offsetY} card top: ${card.offset().top}`);
});

$('#createMikeModal').on('show.bs.modal', event => {
    const viewport = $('#viewport');
    viewport.detach();
    $('#viewportHolder').append(viewport);
});

$('#createMikeModal').on('hide.bs.modal', event => {
    const viewport = $('#viewport');
    viewport.detach();
    $('#viewportResultsHolder').append(viewport);
});

//</%text>