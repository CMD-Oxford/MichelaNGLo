<div class="modal fade" tabindex="-1" role="dialog" id="mutate_modal">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content shadow">
            <div class="modal-header">
                <h5 class="modal-title"><i class="far fa-biohazard"></i> Mutate</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Create a second structure where a set of amino acids are replaced using PyMOL's mutagenesis algorithm.
                    This will alter only the side chain of the residues mutated and does not repack the neighbouring sidechains nor does it account for blackbone torsion.
                    Note that this page will reload for the changes to be made, so make sure you have saved the edits to the text beforehand.
                </p>
                <div class="input-group mb-3" data-html=true data-toggle="tooltip" title="The name is used in the storage and one way of retrieval of the protein structure (<i>e.g.</i>`data-load='my_not_so_easy_to_remember_var_name'` attribute on a prolink). This is actually used as a JS variable, consequently can only contain letters, digits (except as a first character) and underscores, with no spaces or hyphens or other puctionation mark. Non-ASCII characters (<i>e.g.</i> <code>タンパク質</code>) are normally valid letters, but cannot be use in this case.">
                  <div class="input-group-prepend">
                    <span class="input-group-text" id="mutate_name_label">Structure name</span>
                  </div>
                  <input type="text" class="form-control" value="mutant_${len(structure_info)}" aria-label="name" aria-describedby="mutate_name_label" id="mutate_name">
                </div>
                <div class="input-group mb-3">
                  <div class="input-group-prepend">
                    <span class="input-group-text" id="mutate_chain_label">Chain</span>
                  </div>
                  <input type="text" class="form-control" placeholder="A" aria-label="A" aria-describedby="mutate_chain_label" id="mutate_chain">
                </div>
                <div class="input-group" data-toggle="tooltip" title="Space or newline separated. <code>M1W D20D</code> for example.The residue must exist on the structure. NB. The first aa is not checked, so it is up to you to get the residue right.">
                  <div class="input-group-prepend">
                    <span class="input-group-text">List of mutations</span>
                  </div>
                  <textarea class="form-control" aria-label="With textarea" id="mutate_mutations"></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="mutate_create"><i class="far fa-wrench"></i> Create</button>
                    <button type="button" class="btn btn-secondary" data-dismiss="modal"><i class="far fa-sign-out"></i> Close</button>
                </div>
            </div>
        </div>
    </div>
</div>
