import { Controller } from '@hotwired/stimulus'
import Tagify from '@yaireo/tagify';

export default class extends Controller {
    static targets = [ "output" ]

    connect() {
        console.log("Tags controller conected")
        // let whitelist = this.outputTarget.dataset.whitelist.trim().split(/\s*,\s*/);
        new Tagify(
            this.outputTarget,

            {
                // whitelist: whitelist,
                maxTags: 8,
                editTags: 1,
                addTagOnBlur: true,
                duplicates: false
                // autoComplete: { enabled: true },
                // dropdown: {
                //     caseSensitive: true,
                //     maxItems: 20,           // <- mixumum allowed rendered suggestions
                //     classname: "tags-look", // <- custom classname for this dropdown, so it could be targeted
                //     enabled: 0,             // <- show suggestions on focus
                //     closeOnSelect: false    // <- do not hide the suggestions dropdown once an item has been selected
                // }
            }
        );
    }
}

// add tags suggestions