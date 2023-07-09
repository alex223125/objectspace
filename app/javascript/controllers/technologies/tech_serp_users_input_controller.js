import { Controller } from '@hotwired/stimulus'
import Tagify from '@yaireo/tagify';

// const usersList = [
//     { value: 1, name: 'Emma Smith', avatar: 'avatars/300-6.jpg', email: 'e.smith@kpmg.com.au' },
//     { value: 2, name: 'Max Smith', avatar: 'avatars/300-1.jpg', email: 'max@kt.com' },
//     { value: 3, name: 'Sean Bean', avatar: 'avatars/300-5.jpg', email: 'sean@dellito.com' },
//     { value: 4, name: 'Brian Cox', avatar: 'avatars/300-25.jpg', email: 'brian@exchange.com' },
//     { value: 5, name: 'Francis Mitcham', avatar: 'avatars/300-9.jpg', email: 'f.mitcham@kpmg.com.au' },
//     { value: 6, name: 'Dan Wilson', avatar: 'avatars/300-23.jpg', email: 'dam@consilting.com' },
//     { value: 7, name: 'Ana Crown', avatar: 'avatars/300-12.jpg', email: 'ana.cf@limtel.com' },
//     { value: 8, name: 'John Miller', avatar: 'avatars/300-13.jpg', email: 'miller@mapple.com' }
// ];

export default class extends Controller {
    static targets = [ "usersInput" ]

    initialize(){
        this.addAllSuggestionsElm = ""
        this.tagify = ""
    }

    connect() {
        console.log("Tech serp users input controller connected")
        this.usersAsTags();
    }

    disconnect() {
        console.log("Tech serp users input controller disconnected")
    }

    usersAsTags(){
        const usersInput = this.usersInputTarget
        // document.querySelector('input[name=tag]');
        // var classNormal = "block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        this.tagify = new Tagify(usersInput, {
            tagTextProp: 'name', // very important since a custom template is used with this property as text.
                                // allows typing a "value" or a "name" to match input with whitelist
            enforceWhitelist: true,
            skipInvalid: true, // do not temporarily add invalid tags
            maxTags: 10,
            dropdown: {
                maxItems: 20,
                closeOnSelect: false,
                enabled: 0,
                classname: 'users-list',
                searchKeys: ['name', 'username']  // very important to set by which keys to search for suggesttions when typing
            },
            // whitelist: [],
            // maxTags: 10,
            // dropdown: {
            //     maxItems: 20, // <- mixumum allowed rendered suggestions
            //     classname: 'tags-look', // <- custom classname for this dropdown, so it could be targeted
            //     enabled: 0, // <- show suggestions on focus
            //     closeOnSelect: false, // <- do not hide the suggestions dropdown once an item has been selected
            // },
            // tags: {
            //     classname: "block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            // },
            // whitelist: [
            //     { value: 1, name: 'Emma Smith', avatar: 'avatars/300-6.jpg', email: 'e.smith@kpmg.com.au' },
            //     { value: 2, name: 'Max Smith', avatar: 'avatars/300-1.jpg', email: 'max@kt.com' },
            //     { value: 3, name: 'Sean Bean', avatar: 'avatars/300-5.jpg', email: 'sean@dellito.com' },
            //     { value: 4, name: 'Brian Cox', avatar: 'avatars/300-25.jpg', email: 'brian@exchange.com' },
            //     { value: 5, name: 'Francis Mitcham', avatar: 'avatars/300-9.jpg', email: 'f.mitcham@kpmg.com.au' },
            //     { value: 6, name: 'Dan Wilson', avatar: 'avatars/300-23.jpg', email: 'dam@consilting.com' },
            //     { value: 7, name: 'Ana Crown', avatar: 'avatars/300-12.jpg', email: 'ana.cf@limtel.com' },
            //     { value: 8, name: 'John Miller', avatar: 'avatars/300-13.jpg', email: 'miller@mapple.com' }
            // ],
            templates: {
                tag: this.tagTemplate,
                dropdownItem: this.suggestionItemTemplate
            }
        });

        var that = this
        // const url = '/tags_suggestions.json';
        // tag.on('input', function (e) {
        //     that.loadWhiteList(e, tag, url);
        // });

        var onDropdownShow = that.onDropdownShow.bind(that)
        this.tagify.on('dropdown:show dropdown:updated', onDropdownShow)

        var onSelectSuggestion = that.onSelectSuggestion.bind(that)
        this.tagify.on('dropdown:select', onSelectSuggestion)

        const url = '/users_suggestions.json';
        this.tagify.on('input', function (e) {
            console.log("Tagify input triggered")
            that.loadWhiteList(e, that.tagify, url);
        });

        this.tagify.on('edit:start', function (e) {
            console.log("Tagify Edit triggered")
            that.onEditStart(e, that.tagify);
        });


    }

    // PRIVATE

    onEditStart({detail:{tag, data}}){
        console.log("onEditStart({detail:{tag, data}}){")
        console.log(data.name)
        console.log(data.username)
        this.tagify.setTagTextNode(tag, `${data.name} <${data.username}>`)
    }

    tagTemplate(tagData) {
        console.log("TAG DATA")
        console.log(tagData)
        return `
        <tag title="${(tagData.email)}"
                contenteditable='false'
                spellcheck='false'
                tabIndex="-1"
                class="${this.settings.classNames.tag} tagify__tag  inline-flex flex-row items-center gap-2 h-8 py-1 pl-1 pr-3 hover:bg-surface-200 dark:hover:bg-surfacedark-200 focus:bg-surface-400 dark:focus:bg-surfacedark-400  dark:border-gray-200 rounded-[30px] text-sm tracking-[.00714em]"
                ${this.getAttributes(tagData)}
                data-tech_serp_search-target="userAsTagInput"
                >
            <x title='' class='material-symbols-outlined cursor-pointer !text-base tagify__tag__removeBtn' role='button' aria-label='remove tag'></x>
            <div class="inline-flex flex-row items-center gap-2 h-8 py-1 pl-1 pr-3 hover:bg-surface-200 dark:hover:bg-surfacedark-200 focus:bg-surface-400 dark:focus:bg-surfacedark-400 dark:border-gray-200 rounded-[30px] text-sm tracking-[.00714em]">
                <div class="w-6 h-6 rounded-full bg-gray-700 overflow-hidden">
                    <img alt="Avatar" src="${tagData.avatar}" class="w-6 h-6">
                </div>
                <span class="tagify__tag-text">${tagData.username}</span>
            </div>
        </tag>
    `
    }

// <div class="inline-flex flex-row items-center gap-2 h-8 py-1 pl-1 pr-3 hover:bg-surface-200 dark:hover:bg-surfacedark-200 focus:bg-surface-400 dark:focus:bg-surfacedark-400 border border-gray-500 dark:border-gray-200 rounded-[30px] text-sm tracking-[.00714em]">
//     <x title='' className='tagify__tag__removeBtn' role='button' aria-label='remove tag'></x>
//     <div class="w-6 h-6 rounded-full bg-gray-700 overflow-hidden">
//         <img alt="Avatar" src="${tagData.avatar}" class="w-6 h-6">
//     </div>
//     <span className="">${tagData.username}</span>
// </div>



    // suggestionItemTemplate(tagData) {
    //     return `
    //     <div ${this.getAttributes(tagData)}
    //         class='tagify__dropdown__item d-flex align-items-center ${tagData.class ? tagData.class : ""}'
    //         tabindex="0"
    //         role="option">
    //
    //         ${tagData.avatar ? `
    //                 <div class='tagify__dropdown__item__avatar-wrap me-2'>
    //                     <img onerror="this.style.visibility='hidden'"  class="rounded-circle w-50px me-2" src="${tagData.avatar}">
    //                 </div>` : ''
    //     }
    //
    //         <div class="d-flex flex-column">
    //             <strong>${tagData.name}</strong>
    //             <span>${" " + tagData.username}</span>
    //         </div>
    //     </div>
    // `
    // }

    suggestionItemTemplate(tagData) {
        console.log("TAG DATA 222 START")
        console.log(tagData)
        console.log(this.getAttributes(tagData))
        console.log(tagData.class ? tagData.class : "")
        console.log("TAG DATA 222 END")

        return `
            <div ${this.getAttributes(tagData)}
                class='tagify__dropdown__item d-flex align-items-center ${tagData.class ? tagData.class : ""}'
                tabindex="0"
                role="option">
                
                <div class="flex items-center">
                    <img src="${tagData.avatar}" class="rounded-full">
                    <div class="ml-4">
                        <span class="capitalize block text-gray-800">${tagData.name}</span>
                        <span class="text-sm block text-gray-600">${tagData.username}</span>
                    </div>
                </div>
            </div>
        `
    }

// <div className="flex items-center">
//     <img src="https://randomuser.me/api/portraits/thumb/men/96.jpg" className="rounded-full">
//     <div className="ml-4">
//         <span className="capitalize block text-gray-800">Ishaan</span>
//         <span className="text-sm block text-gray-600">ishaan.prajapati@example.com</span>
//     </div>
// </div>




    onDropdownShow(e) {
        var dropdownContentElm = e.detail.tagify.DOM.dropdown.content;

        if (this.tagify.suggestedListItems.length > 1) {
            this.addAllSuggestionsElm = this.getAddAllSuggestionsElm();

            // insert "addAllSuggestionsElm" as the first element in the suggestions list
            dropdownContentElm.insertBefore(this.addAllSuggestionsElm, dropdownContentElm.firstChild)
        }
    }

    onSelectSuggestion(e) {
        console.log("onSelectSuggestion(e) START START START")
        console.log(e)
        console.log(this.tagify)
        console.log(e.detail.elm)
        console.log(this.addAllSuggestionsElm)
        console.log("onSelectSuggestion(e) END END END")

        if (e.detail.elm == this.addAllSuggestionsElm)
            this.tagify.dropdown.selectAll.call(this.tagify);
    }

    getAddAllSuggestionsElm() {
        var that = this
        // suggestions items should be based on "dropdownItem" template
        return this.tagify.parseTemplate('dropdownItem', [{
                class: "addAll",
                name: "Add all",
                // catuon! this is a hack! we use username variable to display amount in dropdownItem template !!!
                username: that.tagify.settings.whitelist.reduce(function (remainingSuggestions, item) {
                    console.log("return that.tagify.isTagDuplicate(item.id)")
                    console.log(item)
                    console.log(item.value)

                    return that.tagify.isTagDuplicate(item.value) ? remainingSuggestions : remainingSuggestions + 1
                }, 0) + " Members"
            }]
        )
    }


    loadWhiteList(e, tagify, url) {
        console.log("Load whitelist triggered!")
        let controller;

        console.log("const query = e.detail.value;")
        console.log(e.detail)
        console.log(e.detail.value)

        const query = e.detail.value;
        tagify.settings.whitelist.length = 0; // reset the whitelist

        controller && controller.abort();
        controller = new AbortController();

        tagify.loading(true).dropdown.hide.call(tagify);

        Rails.ajax({
            type: 'GET',
            url: `${url}?keyword=${query}`,
            dataType: 'json',
            success: (whitelist) => {
                console.log(whitelist)
                // this.tagify.settings.whitelist.splice(0, res.length, ...res);
                tagify.settings.whitelist.splice(0, whitelist.length, ...whitelist);

                console.log("tagify.loading(false).dropdown.show.call(tagify, query);")
                console.log(query)

                tagify.loading(false).dropdown.show.call(tagify, query);
            }
        })
    }



}













// var inputElm = document.querySelector('#kt_tagify_users');

// const usersList = [
//     { value: 1, name: 'Emma Smith', avatar: 'avatars/300-6.jpg', email: 'e.smith@kpmg.com.au' },
//     { value: 2, name: 'Max Smith', avatar: 'avatars/300-1.jpg', email: 'max@kt.com' },
//     { value: 3, name: 'Sean Bean', avatar: 'avatars/300-5.jpg', email: 'sean@dellito.com' },
//     { value: 4, name: 'Brian Cox', avatar: 'avatars/300-25.jpg', email: 'brian@exchange.com' },
//     { value: 5, name: 'Francis Mitcham', avatar: 'avatars/300-9.jpg', email: 'f.mitcham@kpmg.com.au' },
//     { value: 6, name: 'Dan Wilson', avatar: 'avatars/300-23.jpg', email: 'dam@consilting.com' },
//     { value: 7, name: 'Ana Crown', avatar: 'avatars/300-12.jpg', email: 'ana.cf@limtel.com' },
//     { value: 8, name: 'John Miller', avatar: 'avatars/300-13.jpg', email: 'miller@mapple.com' }
// ];

// function tagTemplate(tagData) {
//     return `
//         <tag title="${(tagData.title || tagData.email)}"
//                 contenteditable='false'
//                 spellcheck='false'
//                 tabIndex="-1"
//                 class="${this.settings.classNames.tag} ${tagData.class ? tagData.class : ""}"
//                 ${this.getAttributes(tagData)}>
//             <x title='' class='tagify__tag__removeBtn' role='button' aria-label='remove tag'></x>
//             <div class="d-flex align-items-center">
//                 <div class='tagify__tag__avatar-wrap ps-0'>
//                     <img onerror="this.style.visibility='hidden'" class="rounded-circle w-25px me-2" src="assets/media/${tagData.avatar}">
//                 </div>
//                 <span class='tagify__tag-text'>${tagData.name}</span>
//             </div>
//         </tag>
//     `
// }

// function suggestionItemTemplate(tagData) {
//     return `
//         <div ${this.getAttributes(tagData)}
//             class='tagify__dropdown__item d-flex align-items-center ${tagData.class ? tagData.class : ""}'
//             tabindex="0"
//             role="option">
//
//             ${tagData.avatar ? `
//                     <div class='tagify__dropdown__item__avatar-wrap me-2'>
//                         <img onerror="this.style.visibility='hidden'"  class="rounded-circle w-50px me-2" src="assets/media/${tagData.avatar}">
//                     </div>` : ''
//     }
//
//             <div class="d-flex flex-column">
//                 <strong>${tagData.name}</strong>
//                 <span>${tagData.email}</span>
//             </div>
//         </div>
//     `
// }

// initialize Tagify on the above input node reference
// var tagify = new Tagify(inputElm, {
    // tagTextProp: 'name', // very important since a custom template is used with this property as text. allows typing a "value" or a "name" to match input with whitelist
    // enforceWhitelist: true,
    // skipInvalid: true, // do not remporarily add invalid tags
    // dropdown: {
    //     closeOnSelect: false,
    //     enabled: 0,
    //     classname: 'users-list',
    //     searchKeys: ['name', 'email']  // very important to set by which keys to search for suggesttions when typing
    // },
    // templates: {
    //     tag: tagTemplate,
    //     dropdownItem: suggestionItemTemplate
    // },
//     whitelist: usersList
// })

// tagify.on('dropdown:show dropdown:updated', onDropdownShow)
// tagify.on('dropdown:select', onSelectSuggestion)

// var addAllSuggestionsElm;

// function onDropdownShow(e) {
//     var dropdownContentElm = e.detail.tagify.DOM.dropdown.content;
//
//     if (tagify.suggestedListItems.length > 1) {
//         addAllSuggestionsElm = getAddAllSuggestionsElm();
//
//         // insert "addAllSuggestionsElm" as the first element in the suggestions list
//         dropdownContentElm.insertBefore(addAllSuggestionsElm, dropdownContentElm.firstChild)
//     }
// }

// function onSelectSuggestion(e) {
//     if (e.detail.elm == addAllSuggestionsElm)
//         tagify.dropdown.selectAll.call(tagify);
// }

// create a "add all" custom suggestion element every time the dropdown changes
// function getAddAllSuggestionsElm() {
//     // suggestions items should be based on "dropdownItem" template
//     return tagify.parseTemplate('dropdownItem', [{
//             class: "addAll",
//             name: "Add all",
//             email: tagify.settings.whitelist.reduce(function (remainingSuggestions, item) {
//                 return tagify.isTagDuplicate(item.value) ? remainingSuggestions : remainingSuggestions + 1
//             }, 0) + " Members"
//         }]
//     )
// }