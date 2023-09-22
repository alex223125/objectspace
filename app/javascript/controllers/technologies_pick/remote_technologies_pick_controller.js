// doc: responsibility zone: pass all selected technologies into input
import { Controller } from '@hotwired/stimulus'
import Tagify from '@yaireo/tagify';

export default class extends Controller {
    static targets = [
        'actionsGroupTreeArea',

        'itemsModalInput',
        'itemsFormInput',

        'addItemButton',
        'itemHasAddedButton'
    ]

    static values = {
        simpleClassId: String
    }

    initialize(){

    }

    connect() {
        console.log("remote_technologies_pick controller connected")
        this.loadTree()
        this.selectedItemsFormInput();
        this.selectedItemsModalInput();

        // not it's accessible
        // document.querySelector('#person').controller_name.public_method()
        this.element[this.identifier] = this
    }

    disconnect() {
        console.log("remote_technologies_pick controller disconnected")
    }

    // PUBLIC
    // TODO: add popup on the top of the page "Item added"

    addToCollection(event){
        // 1.prepare data
        let memberableType = event.target.dataset.memberableType
        let memberableId = event.target.dataset.memberableId
        let memberableTitle = event.target.dataset.memberableTitle
        let buttonUniqKey = event.target.dataset.buttonUniqKey

        // 2.pass data to input
        // { value: 100, text: 'kenny', title: 'Kenny McCormick' }
        var item = {value: memberableId, type: memberableType,
                    title: memberableTitle, button_uniq_key: buttonUniqKey }
        this.addItem(item)

        // 3.change button on non clickable button that item added
        let addItemButton = this.addItemButton(buttonUniqKey)
        let itemHasAddedButton = this.itemHasAddedButton(buttonUniqKey)

        addItemButton.classList.add("hidden");
        itemHasAddedButton.classList.remove("hidden");
    }

    sumbitSeletedItems(){
        // 1.pass parameters in form input from modal input
        let selectedItems = this.tagifyModalInput.value
        // 1.1 add to whitelist so it can pass the filter
        this.tagifyFormInput.whitelist = selectedItems
        // 1.2 add in input
        this.tagifyFormInput.removeAllTags()
        this.tagifyFormInput.addTags(selectedItems)
    }

    // PRIVATE

    selectedItemsFormInput(){
        var that = this
        let itemsInput = this.itemsFormInputTarget
        this.tagifyFormInput = new Tagify(itemsInput, {
            whitelist: [],
            enforceWhitelist: true,
            skipInvalid: true, // do not temporarily add invalid tags
            maxTags: 100,
            dropdown: {
                enabled: false
            },
            userInput: false, // prevents user for editing input data
            templates: {
                tag: this.itemTemplate
            }
        });

        // const url = '/tags_suggestions.json';
        // this.tagify.on('input', function (e) {
        //     that.loadWhiteList(e, that.tagify, url);
        // });
        this.tagifyFormInput.on('remove', function (e) {
            console.log("remove event triggered")
            that.removeItem(e)
        });
    }

    selectedItemsModalInput(){
        var that = this
        let itemsInput = this.itemsModalInputTarget
        this.tagifyModalInput = new Tagify(itemsInput, {
            whitelist: [],
            enforceWhitelist: true,
            skipInvalid: true, // do not temporarily add invalid tags
            maxTags: 100,
            dropdown: {
                enabled: false
            },
            templates: {
                tag: this.itemTemplate
            }
        });

        // const url = '/tags_suggestions.json';
        // this.tagify.on('input', function (e) {
        //     that.loadWhiteList(e, that.tagify, url);
        // });
        this.tagifyModalInput.on('remove', function (e) {
            console.log("remove event triggered")
            that.removeItem(e)
        });
    }


    addItem(item){
        // 1.add to whitelist so it can pass the filter
        this.tagifyModalInput.whitelist.push(item)
        // 2.add in input
        this.tagifyModalInput.addTags(([item]))
        // tagify.addTags(["banana", "orange", "apple"])
    }

    removeItem(e){
        let buttonUniqKey = e.detail.data.button_uniq_key

        // hide 'added' button and display 'add' button
        let addItemButton = this.addItemButton(buttonUniqKey)
        let itemHasAddedButton = this.itemHasAddedButton(buttonUniqKey)
        addItemButton.classList.remove("hidden");
        itemHasAddedButton.classList.add("hidden");

        // remove from dropdown
        this.tagifyFormInput.whitelist.pop(e)
    }

    addItemButton(buttonUniqKey){
        let addItemButtonPrefix = "add_item_button_"
        return this.addItemButtonTargets.find(target => target.id == (addItemButtonPrefix + buttonUniqKey))
    }

    itemHasAddedButton(buttonUniqKey){
        let itemHasAddedButtonPrefix = "item_has_added_button_"
        return this.itemHasAddedButtonTargets.find(target => target.id == (itemHasAddedButtonPrefix + buttonUniqKey))
    }

    itemTemplate(tagData, {settings: _s}) {
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
                <span class="${_s.classNames.tagText}">${tagData.title}</span>
            </div>
        </tag>`
    }


    // TODO 1.add awaiting animation + realod
    // TODO 2.load starting only when modal is opened
    loadTree(){
        let simpleClassId = this.simpleClassIdValue
        var url = `/simple_class/simple_classes/${simpleClassId}/tree_view`

        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("Tree view loaded!")
                this.insertView(data)
            }
        })
    }

    insertView(data){
        this.actionsGroupTreeAreaTarget.insertAdjacentHTML('beforeend', data.tree_view)
    }

}