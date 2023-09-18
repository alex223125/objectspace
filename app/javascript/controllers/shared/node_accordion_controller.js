// responsibility zone - open and close accordions
// potentially ajax to get step
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static values = {
        // "opened" or "closed"
        initialState: String,

        headerOpenedClass: String,
        headerClosedClass: String,

        headerSvgClosedClass: String,
        headerSvgOpenedClass: String,

        contentOpenedClass: String,
        contentClosedClass: String
    };


    static targets = [
        'headerButton',
        'targetContentCard',
        'headerSvg'
    ]

    initialize() {
        console.log("Accordion controller initialized")
        this.element.controller = this;
    }

    connect() {
        console.log("Accordion controller connected")
        this.init();

    }

    disconnect() {
        console.log("Accordion controller disconnected")
    }


    // PUBLIC
    toggle(e) {
        console.log("toggle(e)")
        let toggler = this.headerButtonTarget
        if (this.isOpened(toggler)) {
            this.close(toggler);
        } else {
            this.open(toggler);
        }
    }

    reduceHeightOfParent(){
        var parentController = this.element.closest("[data-controller~='node_accordion']").controller;
        parentController.targetContentCardTarget.removeAttribute("style")
    }

    increaseHeightOfParent(){
        // var parentController = this.element.closest("[data-controller~='node_accordion']").controller;
        // parentController.targetContentCardTarget.style.height = parentController.targetContentCardTarget.scrollHeight + 'px';

        // 1.select whole content controller
        var contentAreaController = this.element.closest("[data-controller~='content_area']").controller;
        var allAccordions = contentAreaController.areaTarget.querySelectorAll("[data-controller~='node_accordion']");

        // console.log("allAccordions")
        // console.log(allAccordions)

        // 2.change height for each accordion
        allAccordions.forEach((accordionController) => {
            let controller = accordionController.controller

            if (controller != undefined) {
                // console.log("controller")
                // console.log(controller)

                // console.log("222222222222222222222222")
                // console.log(controller.targetContentCardTarget)
                // console.log(controller.targetContentCardTarget.style)

                // why: during first load of the page scrollHeight is 0
                if (controller.targetContentCardTarget.scrollHeight == 0) {
                    // do nothing
                } else {
                    controller.targetContentCardTarget.style.height = controller.targetContentCardTarget.scrollHeight + 'px';
                }
                // console.log(sentence);
            }


        });
    }

    // updateHeight(){
    //     // this.targetContentCardTarget.style.height = this.targetContentCardTarget.scrollHeight + 'px';
    //     // var parentController = this.element.closest("[data-controller~='node_accordion']").controller;
    //     // parentController.targetContentCardTarget.style.height = parentController.targetContentCardTarget.scrollHeight + 'px';
    //
    //     // var parentControllers = this.element.querySelectorAll("[data-controller~='node_accordion']");
    //     // console.log(this)
    //     // var aaa = window.querySelectorAll("[data-controller~='node_accordion']");
    //     // console.log(aaa)
    //     // console.log(parentControllers)
    //     // parentControllers.forEach((parentController) => {
    //     //     let controller = parentController.controller
    //     //     controller.targetContentCardTarget.style.height = controller.targetContentCardTarget.scrollHeight + 'px';
    //     //     // console.log(sentence);
    //     // });
    //
    //     // 1.select whole content controller
    //     var contentAreaController = this.element.closest("[data-controller~='content_area']").controller;
    //     var allAccordions = contentAreaController.areaTarget.querySelectorAll("[data-controller~='node_accordion']");
    //     // 2.change height for each accordion
    //     allAccordions.forEach((accordionController) => {
    //         let controller = accordionController.controller
    //         controller.targetContentCardTarget.style.height = controller.targetContentCardTarget.scrollHeight + 'px';
    //         // console.log(sentence);
    //     });
    // }

    // PRIVATE

    init() {
        console.log("Init triggered")
        let toggler = this.headerButtonTarget
        if (this.initialStateValue == "opened") {
            this.open(toggler);
        } else {
            this.close(toggler);
        }
    }


    isOpened(toggler){
        if (toggler.className == this.headerOpenedClassValue) {
          return true
        } else {
          return false
        }
    }

    open(toggler) {
        console.log("open(toggler) {")
        let content = this.targetContentCardTarget
        this.show(toggler, content);
    }

    close(toggler) {
        console.log("close(toggler) {")
        let content = this.targetContentCardTarget
        this.hide(toggler, content);
    }

    show(toggler, content, transition = true) {
        console.log("show(toggler")
        // if (transition) {
        //     content.style.height = '0px';
        //     content.removeEventListener('transitionend', this.transitionEnd);
        //     content.addEventListener('transitionend', this.transitionEnd);
        //     setTimeout(() => {
        //         content.style.height = content.scrollHeight + 'px';
        //         // var parentController = this.element.closest("[data-controller~='node_accordion']").controller;
        //         // parentController.targetContentCardTarget.style.height = parentController.targetContentCardTarget.scrollHeight + 'px';
        //     }, 0);
        //
        // }

        this.toggleClass(toggler, content, true);

        // console.log("1111111111111111111111111111111111111111111111")
        // console.log(content)
        // console.log(content.style)
        // console.log(content.style.height)
        // console.log(content.scrollHeight)

        // why: during first load of the page scrollHeight is 0
        if (content.scrollHeight == 0) {
            // do nothing
        } else {
            content.style.height = content.scrollHeight + 'px';
        }

        // if (content.style.height > content.scrollHeight) {
        //     // do nothing
        // } else {
        //     content.style.height = content.scrollHeight + 'px';
        // }

        // update height of parent accordion
        const trigger = new CustomEvent("increase-height");
        window.dispatchEvent(trigger);
    }


    hide(toggler, content, transition = true) {
        console.log("hide(toggler")
        // if (transition) {
        //     // content.style.height = content.scrollHeight + 'px';
        //     // content.removeEventListener('transitionend', this.transitionEnd);
        //     // content.addEventListener('transitionend', this.transitionEnd);
        //     setTimeout(() => {
        //         content.style.height = '0px';
        //         // var parentController = this.element.closest("[data-controller~='node_accordion']").controller;
        //         // parentController.targetContentCardTarget.style.height = parentController.targetContentCardTarget.scrollHeight + 'px';
        //     }, 0);
        //
        // }

        this.toggleClass(toggler, content, false);

        content.style.height = '0px';

        // update height of parent accordions
        const trigger = new CustomEvent("reduce-height");
        window.dispatchEvent(trigger);
    }

    // transitionEnd(e) {
    //     console.log("transitionEnd(e)")
    //     e.target.style.height = '';
    // }

    toggleClass(toggler, content, opened) {
        console.log("toggleClass(toggler, content, opened)")
        if (opened) {
            // toggler.className = this.headerOpenedClassValue
            // content.className = this.contentOpenedClassValue
            // console.log("toggleClass - open case triggered")
            // console.log(this.headerOpenedClassValue)
            // console.log(this.contentOpenedClassValue)

            toggler.setAttribute('class', this.headerOpenedClassValue)
            content.setAttribute('class', this.contentOpenedClassValue)

            // console.log(toggler)
            // console.log(content)

            this.headerSvgTarget.setAttribute('class', this.headerSvgOpenedClassValue)
        } else {
            // toggler.className = this.headerClosedClassValue
            // content.className = this.contentClosedClassValue
            toggler.setAttribute('class', this.headerClosedClassValue)
            content.setAttribute('class', this.contentClosedClassValue)
            this.headerSvgTarget.setAttribute('class', this.headerSvgClosedClassValue)
        }
    }

}