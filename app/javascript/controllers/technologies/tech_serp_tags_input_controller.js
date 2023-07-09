import { Controller } from '@hotwired/stimulus'
import Tagify from '@yaireo/tagify';

export default class extends Controller {
    static targets = [ "tagInput" ]

    initialize(){
        console.log("Tech serp tags input controller initialized")
    }

    connect() {
        console.log("Tech serp tags input controller connected")
        this.tags();
        console.log("Tags input created")
        // let whitelist = this.outputTarget.dataset.whitelist.trim().split(/\s*,\s*/);
    }

    addTag(tag){
        // console.log("this.tagify.addTags(tag)")
        // console.log("NEW TAG TAG TAG")
        // console.log(tag)
        var tag = {value:tag}
        // console.log(tag)
        this.tagify.whitelist.push(tag)
        // console.log(this.tagify.whitelist)
        this.tagify.addTags(([tag]))
        // tagify.addTags(["banana", "orange", "apple"])
    }

    tags(){
        var that = this
        const titleInput = this.tagInputTarget
            // document.querySelector('input[name=tag]');
        // var classNormal = "block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        this.tagify = new Tagify(titleInput, {
            whitelist: [],
            enforceWhitelist: true,
            skipInvalid: true, // do not temporarily add invalid tags
            maxTags: 10,
            dropdown: {
                maxItems: 20, // <- mixumum allowed rendered suggestions
                classname: 'tags-look', // <- custom classname for this dropdown, so it could be targeted
                enabled: 0, // <- show suggestions on focus
                closeOnSelect: false, // <- do not hide the suggestions dropdown once an item has been selected
            },
            templates: {
                tag: this.tagTemplate
            }
            // tags: {
            //     classname: "block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            // }
            // templates: {
            //     wrapper(input, _s){
            //         return `<tags class="${classNormal} ${_s.mode ? `${_s.classNames[_s.mode + "Mode"]}` : ""} ${input.className}"
            //                     ${_s.readonly ? 'readonly' : ''}
            //                     ${_s.disabled ? 'disabled' : ''}
            //                     ${_s.required ? 'required' : ''}
            //                     ${_s.mode === 'select' ? "spellcheck='false'" : ''}
            //                     tabIndex="-1">
            //             <span ${!_s.readonly && _s.userInput ? 'contenteditable' : ''} tabIndex="0" data-placeholder="${_s.placeholder || '&#8203;'}" aria-placeholder="${_s.placeholder || ''}"
            //                 class="${_s.classNames.input}"
            //                 role="textbox"
            //                 aria-autocomplete="both"
            //                 aria-multiline="${_s.mode=='mix'?true:false}"></span>
            //                 &#8203;
            //         </tags>`
            //     }
            // }
        });

        const url = '/tags_suggestions.json';
        this.tagify.on('input', function (e) {
            that.loadWhiteList(e, that.tagify, url);
        });
    }

    // PRIVATE

    loadWhiteList(e, tag, url) {
        let controller;
        const query = e.detail.value;
        tag.settings.whitelist.length = 0; // reset the whitelist

        controller && controller.abort();
        controller = new AbortController();

        tag.loading(true).dropdown.hide.call(tag);

        Rails.ajax({
            type: 'GET',
            url: `${url}?keyword=${query}`,
            dataType: 'json',
            success: (whitelist) => {
                console.log(whitelist)
                // this.tagify.settings.whitelist.splice(0, res.length, ...res);
                tag.settings.whitelist.splice(0, whitelist.length, ...whitelist);
                tag.loading(false).dropdown.show.call(tag, query);
            }
        })
    }

    tagTemplate(tagData, {settings: _s}) {
        return `<tag title="${(tagData.title || tagData.value)}"
                    contenteditable='false'
                    spellcheck='false'
                    tabIndex="${_s.a11y.focusableTags ? 0 : -1}"
                    class="${_s.classNames.tag} ${tagData.class || ""}"
                    ${this.getAttributes(tagData)}
                    data-tech_serp_search-target="tagInput"
                    >
            <x title='' class="${_s.classNames.tagX}" role='button' aria-label='remove tag'></x>
            <div>
                <span class="${_s.classNames.tagText}">${tagData[_s.tagTextProp] || tagData.value}</span>
            </div>
        </tag>`
    }


}


// import { Controller } from "stimulus"
// import Tagify from '@yaireo/tagify'
//
// export default class extends Controller {
//     connect() {
//         this.languages();
//     }
//
//     languages() {
//         var that = this;
//         const url = '/languages.json';
//         const titleInput = document.querySelector('input[name=language]');
//         const language = new Tagify(titleInput, {
//             whitelist: [],
//             maxTags: 10,
//             dropdown: {
//                 maxItems: 20, // <- mixumum allowed rendered suggestions
//                 classname: 'tags-look', // <- custom classname for this dropdown, so it could be targeted
//                 enabled: 0, // <- show suggestions on focus
//                 closeOnSelect: false, // <- do not hide the suggestions dropdown once an item has been selected
//             },
//         });
//
//         language.on('focus', function (e) {
//             that.loadWhiteList(e, language, url);
//         });
//     }
//
//
//     loadWhiteList(e, language, url) {
//         let controller;
//         const value = e.detail.value;
//         language.settings.whitelist.length = 0; // reset the whitelist
//
//         controller && controller.abort();
//         controller = new AbortController();
//
//         language.loading(true).dropdown.hide.call(language);
//
//         fetch(`${url}?value=${value}`, { signal: controller.signal })
//             .then((RES) => RES.json())
//             .then(function (whitelist) {
//                 language.settings.whitelist.splice(
//                     0,
//                     whitelist.length,
//                     ...whitelist
//                 );
//                 language.loading(false).dropdown.show.call(language, value);
//             });
//     }
// }
