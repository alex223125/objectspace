import { Controller } from '@hotwired/stimulus'
import Cropper from "cropperjs";
import { useMutation } from 'stimulus-use'

export default class extends Controller {
    // TODO remove target which are not in use
    static targets = ["croppingModalButton", "avatarInput", "cropperContainer", "croppingModalPopup",
        "cropButton", "modalImage", "inputInstance", "croppedImageResult", "croppedImagePreview", "closeModalButton"];

    initialize(){
        console.log("Users avatar input controller initialized")
        this.cropper = ""
        this.isModalOpen = ""
    }

    connect() {
        console.log("Users avatar input controller connected")
        useMutation(this, {attributes: true, childList: true, characterData: false, subtree:true})
    }

    disconnect() {
        console.log("Users avatar input controller disconnected")
    }

    mutate(mutationsList) {
        for(let mutation of mutationsList) {
            // console.log("mutation")
            // console.log(mutation)

            // this is hack to skip multiple mutations after one event of modal opening
            // mutte procues 4 events instead of one
            if (this.isModalOpen == true) {
                // do nothing
            } else {
                if (mutation.target.id == "modal-image") {
                    if (this.croppingModalPopupTarget.classList.contains("hidden")) {
                        // handle modal close case
                        console.log('the modal is now hidden');
                    } else {
                        // handle modal opened case
                        this.isModalOpen = true
                        this.handleModalOpen()
                        console.log('the modal is now open');
                    }
                }
            }
        }
    }


    // PUBLIC

    handleFileInputChange(e){
        console.log("DO DO DO")

        var files = e.target.files;
        console.log("var files = e.target.files;")
        console.log(files)

        var that = this
        var reader;
        var file;
        var url;

        if (files && files.length > 0) {
            file = files[0];

            if (URL) {
                this.setImageUrl(URL.createObjectURL(file))
            } else if (FileReader) {
                var that = this
                reader = new FileReader();
                reader.onload = function (e) {
                    that.setImageUrl(reader.result)
                };
                reader.readAsDataURL(file);
            }
        }

        console.log("this.croppingModalButtonTarget")
        console.log(this.croppingModalButtonTarget)
        this.croppingModalButtonTarget.click()
    }

    handleModalClose(){
        this.closeModalButtonTarget.click()
        this.destroyCroppingData()
        this.isModalOpen = false
    }

    crop(){
        // TODO restric by MB size!

        console.log("this.cropper")
        console.log(this.cropper)

        // this.cropper.ready = true
        var canvas = this.cropper.getCroppedCanvas({
            width: 160,
            height: 90,
            minWidth: 256,
            minHeight: 256,
            maxWidth: 4096,
            maxHeight: 4096,
            fillColor: '#fff',
            imageSmoothingEnabled: false,
            imageSmoothingQuality: 'high',
        });

        console.log("canvas")
        console.log(canvas)

        var that = this
        canvas.toBlob(function(blob) {

            var url = URL.createObjectURL(blob);

            var reader = new FileReader();
            reader.readAsDataURL(blob);

            console.log("THAAAT 1")
            console.log(that)

            reader.onloadend = function() {
                var base64data = reader.result;
                console.log("var base64data = reader.result;")
                console.log(base64data)

                console.log("THAAAT 2")
                console.log(that)

                // 1) Assign value and display cropped image
                that.croppedImagePreviewTarget.src = base64data
                that.croppedImagePreviewTarget.style.display = ""
                that.croppedImagePreviewTarget.width = 400
                that.croppedImagePreviewTarget.height = 400


                // 2) Change value in modal
                that.modalImageTarget.value = base64data
                console.log("that.modalImageTarget.value = base64data")
                console.log(that.modalImageTarget)

                // 3) Assing to input which using in request params
                // that.croppedImageResultTarget.value = base64data
                that.croppedImageResultTarget.setAttribute('value', base64data)
                console.log("that.croppedImageResultTarget.value = base64data")
                console.log(that.croppedImageResultTarget)

                // close modal
                that.closeModalButtonTarget.click()

                // destroy cropping data
                that.destroyCroppingData()

                that.isModalOpen = false
            }
        });
    }

    // PRIVATE

    handleModalOpen(){
        // var image = this.inputInstanceTarget.getElementById('modal-image').src
        console.log("var image = this.modalImageTarget")
        console.log(this.modalImageTarget)

        // console.log("THIS CROPPER BEFORE INITIALIZATION")
        // console.log(this.cropper)

        this.cropper = new Cropper(this.modalImageTarget, {
            autoCropArea: 1,
            aspectRatio: 1,
            viewMode: 0,
            dragMode: "move",
            responsive: true,
            preview: '.preview',
            minContainerHeight: 500,
        });
        // console.log("THIS CROPPER AFTER INITIALIZATION")
        // console.log(this.cropper)
    }

    setImageUrl(url){
        console.log("this.modalImageTarget")
        console.log(this.modalImageTarget)
        this.modalImageTarget.src = url;
    }

    destroyCroppingData(){
        console.log("Cropper destroy triggered")
        if (this.cropper == null) {
            // do nothing
        } else {
            this.cropper.destroy();
            this.cropper = null;
        }
    }

}