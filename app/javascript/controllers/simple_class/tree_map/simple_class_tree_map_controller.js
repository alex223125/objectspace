// doc: responsibility zone - display small details of class in modal
import { Controller } from '@hotwired/stimulus';
import { jstree } from 'jstree';
import jquery from 'jquery'
// const data = [{
//     id: "padre1",
//     parent: "#",
//     text: "Padre 1",
//     icon: 'fa fa-star text-warning'
// }, {
//     id: "padre2",
//     parent: "#",
//     text: "Padre 2"
// }, {
//     id: "id3",
//     parent: "padre1",
//     text: "Figlio 1 di padre 1"
// }, {
//     id: "id4",
//     parent: "padre1",
//     text: "Figlio 2 di padre 1"
// }, {
//     id: "id5",
//     parent: "padre2",
//     text: "Figlio 1 di padre 2"
// }, {
//     id: "id6",
//     parent: "id5",
//     text: "Figlio 1 di figlio 1 di padre 2"
// }, {
//     id: "id7",
//     parent: "id5",
//     text: "Figlio 2 di figlio 1 di padre 2"
// }, {
//     id: "id8",
//     parent: "id5",
//     text: "Figlio 3 di figlio 1 di padre 2"
// }, {
//     id: "id9",
//     parent: "#",
//     text: "Figlio 3 di figlio 1 di padre 2"
// }]

// prevents hover css to appear on hover
jquery.jstree.plugins.nohover = function () { this.hover_node = jQuery.noop; };

jquery.jstree.core.prototype._create_prototype_node = function () {
    var _node = document.createElement('LI'), _temp1, _temp2;
    _node.setAttribute('role', 'none');
    _temp1 = document.createElement('I');
    _temp1.className = 'jstree-icon jstree-ocl';
    _temp1.setAttribute('role', 'presentation');
    _node.appendChild(_temp1);
    _temp1 = document.createElement('div');
    _temp1.className = 'jstree-anchor';

    // data-target here:
    _temp1.setAttribute('data-target', 'simple_class_tree_map.anchor');
    _temp1.setAttribute('data-action', 'click->simple_class_tree_map#toggleNode');
    // we don't use it:
    // _temp1.setAttribute('href','#');
    _temp1.setAttribute('tabindex','-1');
    _temp1.setAttribute('role', 'treeitem');
    _temp2 = document.createElement('I');
    _temp2.className = 'jstree-icon jstree-themeicon';
    _temp2.setAttribute('role', 'presentation');
    _temp1.appendChild(_temp2);
    _node.appendChild(_temp1);
    _temp1 = _temp2 = null;

    return _node;
}



export default class extends Controller {

    static targets = [
        'treeMapArea',
        'tree',
        'searchInput',
        'dynamicTree',
        'anchor'
    ]

    initialize() {
        console.log("class tree map controller initialized")
    }

    connect() {
        console.log("class tree map controller connected")
        var that = this
        this.loadTreeTemplate(function() {
            that.initializeTree();
        });
    }

    disconnect() {
        console.log("class tree map disconnected")
    }

    initializeTree(){
        this.treeInstance = $(this.dynamicTreeTarget).jstree({
            plugins: ['search', 'types', 'nohover', 'themes', 'changed'],
            // plugins: ['checkbox', 'search', 'changed', 'contextmenu'],
            // contextmenu: {
            //     select_node: false,
            //     items: this.contextMenu
            // },
            checkbox: {
                three_state: false
            },
            search: {
                show_only_matches: true
            },
            core: {
                // data: data,
                themes: {
                    "name": "default",
                    "variant" : "large",
                    "icons": false,
                }
            },

            // 'core': {
            //     'themes': {
            //         'name': 'proton',
            //         'responsive': true
            //     }
            // }
            // types : {
            //     // the default type
            //     "default" : {
            //         hover_node: false
            //         // "max_children"	: -1,
            //         // "max_depth"		: -1,
            //         // "valid_children": "all"
            //
            //         // Bound functions - you can bind any other function here (using boolean or function)
            //
            //         // TODO: draw diagonal with all related methods of attribute
            //         //"select_node"	: true,
            //         //"open_node"	: true,
            //         //"close_node"	: true,
            //         //"create_node"	: true,
            //         //"delete_node"	: true
            //     }
            // },
            // "types": {
            //     "types": {
            //         "root" : {
            //             "hover_node" : false
            //         },
            //         "default": {
            //             "hover_node" : false,
            //         },
            //         "none":{
            //             "hover_node" : false,
            //         }
            //     }
            // }



        });

        // selected plugin is disabled
        this.treeInstance.on("changed.jstree", function(e, data) {
            console.log('Selected ' + data.changed.selected);
            console.log('Deselected ' + data.changed.deselected);
        })


        this.treeInstance.on("create_node.jstree", function (e, data) {
            $("li#"+data.node.id).find("a").replace("<a>", "<div>");
        });


        // this.anchorTargets.map(anchor => {
        //     $(anchor).on('click', () => {
        //         console.log("11 click event happend")
        //         var treeOpenCloseElement = 'jstree-icon jstree-ocl'
        //         var previousSibling = anchor.previousSibling
        //         if (previousSibling.className == treeOpenCloseElement){
        //             previousSibling.click()
        //         }
        //     });
        // })





        var to = false;

        var that = this
        $(this.searchInputTarget).keyup(function() {
            if (to) {
                clearTimeout(to);
            }
            to = setTimeout(function() {
                var searchTerm = $(that.searchInputTarget).val();
                $(that.dynamicTreeTarget).jstree(true).search(searchTerm);
            }, 250);
        });

    }

    // PUBLIC
    toggleNode(e){
        console.log("toggleNode fired")
        var treeOpenCloseElement = 'jstree-icon jstree-ocl'
        var previousSibling = e.currentTarget.previousSibling
        if (previousSibling.className == treeOpenCloseElement){
            previousSibling.click()
        }
    }

    // PRIVATE

    contextMenu(node) {
        var items = {};
        if (node.children.length > 0) {
            items.pickAll = {
                label: 'Pick all',
                icon: 'fa fa-check-square',
                action: function(current) {
                    console.log(this);
                    console.log(current);
                }
            }
        }
        return items;
    }

    loadTreeTemplate(){
        const uuid = this.setUuid()
        const params = this.setParams()

        var url = `/simple_class/simple_classes/${uuid}/tree_map?${params}`

        // make request
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("Tree template loaded!")
                this.insert(data)
            }
        })
    }

    setParams(){
        if (this.data.get("treeType") == "technology_pick"){
            return 'map_type=technology_pick'
        } else {
            return 'map_type=regular_view'
        }
    }

    insert(data){
        // this.instructionPreviewContainer.innerHTML = "";
        this.treeTarget.insertAdjacentHTML('beforeend', data.tree)
        // should be executed after tree got
        // rendered on div
        this.initializeTree();
    }

    setUuid(){
        // technology pick case
        if (typeof this.data.get("simpleClassUuid") !== "undefined" && this.data.get("simpleClassUuid") !== null  ) {
            return this.data.get("simpleClassUuid")
        } else {
            var contentAreaController = this.contentAreaController()
            console.log("contentAreaController:")
            console.log(contentAreaController)
            var value = contentAreaController.uuidInputTarget.value

            console.log("contentAreaController.uuidInputTarget:")
            console.log(contentAreaController.uuidInputTarget)

            return value
        }
    }

    contentAreaController(){
        return this.element.closest("[data-controller~='content_area']").controller;
    }

}
