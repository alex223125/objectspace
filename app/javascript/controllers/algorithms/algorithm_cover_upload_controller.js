import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"
import Panzoom from "@panzoom/panzoom"

export default class extends Controller {
    static targets = [ "input", "preview", "cropperContainer", "cropImage", "filterSelect",
        "brightnessSlider", "brightnessVal", "contrastSlider", "contrastVal", "zoomSlider",
        "zoomVal", "canvas", "panzoomContainer", "comicStyleSelect" ]

    connect() {
        this.cropper = null
        console.log("Algorithm cover quest engine initialized successfully with Cropper v2.")

        this.currentScale = 1.0
        this.brightness = 100
        this.contrast = 100
        this.filterType = "none"
        this.rotationAngle = 0
        this.flipH = 1
        this.flipV = 1

        // CRITICAL FIX: Ensure a bulletproof fallback aspect ratio baseline metric is instantiated
        this.targetAspectRatio = this.targetAspectRatio || 3

        this.coverImageInstance = null
        this.ctx = null
    }


    /**
     * 1. Handles Image Data Streams Selection
     * Fully optimized for CropperJS v2 Web Components and Form inputs tracking
     */
    handleSelection(event) {
        const file = event.target.files[0]
        if (!file) return

        const reader = new FileReader()
        reader.onload = (e) => {
            // Unhide the main editor workspace view layout panels
            this.cropperContainerTarget.classList.remove("hidden")
            this.cropImageTarget.src = e.target.result

            // Store clean baseline parameters for image reset features
            this.originalUploadedImageBase64 = e.target.result;

            if (this.hasZoomSliderTarget) {
                this.zoomSliderTarget.value = "100"
                this.zoomValTarget.textContent = "100%"
            }

            // Clean up old active library memory instances to prevent event collisions
            if (this.cropper) {
                this.cropper.destroy()
                this.cropper = null
            }

            console.log("[Cropper v2] Initializing dynamic 3:1 aspect ratio banner workspace...");

            // Instantiate CropperJS v2 on your plain ERB <img> tag target
            // We pass a custom template string to overwrite the internal shadow DOM markup
            this.cropper = new Cropper(this.cropImageTarget, {
                container: this.panzoomContainerTarget,

                // Overrides the default layout inside the web component's shadow root
                // action="crop" allows box mutation scaling actions
                // translatable and scalable allow background image transformation panning
                template: `
        <cropper-canvas action="crop" background="false" style="width: 100%; height: 100%;">
          <cropper-image 
            translatable="true" 
            scalable="true" 
            rotatable="false"
            skewable="false">
          </cropper-image>
          
          <cropper-shade></cropper-shade>
          
          <!-- Box is highly interactive but locked strictly onto the 3:1 geometry scale matching aspect-[21/7] -->
          <cropper-selection 
            aspect-ratio="3" 
            initial-coverage="0.8" 
            movable="true" 
            resizable="true"
            keyboard="true">
            
            <cropper-grid covered></cropper-grid>
            <cropper-crosshair centered></cropper-crosshair>
            
            <!-- CRITICAL FOR V2: These explicit handle definitions map the mouse gestures to the bounding corners -->
            <cropper-handle action="move" theme-color="rgba(255, 255, 255, 0.5)"></cropper-handle>
            <cropper-handle action="e-resize"></cropper-handle>
            <cropper-handle action="w-resize"></cropper-handle>
            <cropper-handle action="n-resize"></cropper-handle>
            <cropper-handle action="s-resize"></cropper-handle>
            <cropper-handle action="ne-resize"></cropper-handle>
            <cropper-handle action="nw-resize"></cropper-handle>
            <cropper-handle action="se-resize"></cropper-handle>
            <cropper-handle action="sw-resize"></cropper-handle>
          </cropper-selection>
        </cropper-canvas>
      `,

                // Lifecycle hook executed immediately after the Web Components finish mounting
                ready: () => {
                    console.log("[Cropper v2] 3:1 Interactive layout handles mapped successfully.");

                    const canvas = this.cropper.getCropperCanvas();
                    if (canvas) {
                        const selection = canvas.querySelector('cropper-selection');
                        if (selection) {
                            // Hard force the mathematical 3:1 geometry scales parameters
                            selection.aspectRatio = 3;
                            selection.resizable = true;
                            selection.movable = true;
                        }
                    }
                }
            });
        }
        reader.readAsDataURL(file)
    }


    /**
     * Continuous Zoom Range Slider Handler (Powered by Panzoom)
     * Connected to: data-action="input->algorithm_cover_upload#scaleCanvasZoom"
     */
    scaleCanvasZoom(event) {
        if (!this.panzoomInstance) return;

        // Safely capture the slider element whether called via interaction or button override
        const sliderElement = (event && event.target) ? event.target : this.zoomSliderTarget;
        if (!sliderElement) return;

        const sliderValue = parseFloat(sliderElement.value);

        // Convert range boundaries (50-200) into a clean zoom scale factor (0.5 to 2.0)
        const targetScale = sliderValue / 100;

        // Native Panzoom API: Fire hardware-accelerated 2D CSS scaling transform
        this.panzoomInstance.zoom(targetScale, { animate: true });

        // Update the textual percentage value live badge indicator label on screen
        if (this.hasZoomValTarget) {
            this.zoomValTarget.textContent = `${Math.round(sliderValue)}%`;
        }
    }

    /**
     * Fast Step Zoom In Button (+)
     * Connected to: data-action="click->algorithm_cover_upload#zoomInStep"
     */
    zoomInStep(event) {
        event.preventDefault();
        if (!this.panzoomInstance || !this.hasZoomSliderTarget) return;

        const slider = this.zoomSliderTarget;
        const currentVal = parseInt(slider.value, 10);
        const maxVal = parseInt(slider.max, 10) || 200;

        // Calculate next incremental step up to max ceiling limits
        const nextVal = Math.min(currentVal + 15, maxVal);
        slider.value = nextVal;

        // Trigger the unified Panzoom pipeline with a safe null event reference
        this.scaleCanvasZoom(null);
    }

    /**
     * Fast Step Zoom Out Button (-)
     * Connected to: data-action="click->algorithm_cover_upload#zoomOutStep"
     */
    zoomOutStep(event) {
        event.preventDefault();
        if (!this.panzoomInstance || !this.hasZoomSliderTarget) return;

        const slider = this.zoomSliderTarget;
        const currentVal = parseInt(slider.value, 10);
        const minVal = parseInt(slider.min, 10) || 50;

        // Calculate next decremental step down to min floor limits
        const nextVal = Math.max(currentVal - 15, minVal);
        slider.value = nextVal;

        // Trigger the unified Panzoom pipeline with a safe null event reference
        this.scaleCanvasZoom(null);
    }



    /**
     * 4. Dynamic Aspect Ratio Modifier Action Triggers Panel Tabs
     * data-action="click->algorithm_cover_upload#changeAspectRatio"
     */
    changeAspectRatio(event) {
        event.preventDefault()
        if (!this.cropper) return

        const ratio = parseFloat(event.currentTarget.dataset.ratio)

        // CRITICAL FIX: Use Cropper's setAspectRatio method to live-morph dimensions grids
        this.cropper.setAspectRatio(ratio)
    }

    // B. Commit & Seal current parameters into standard form upload parameters
    // async applyModifications(event) {
    //     event.preventDefault()
    //     if (!this.cropper) return
    //
    //
    //
    //     try {
    //
    //         //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //         // Add this rotation burn sequence inside your applyModifications() try block:
    //         const cropperImage = this.element.querySelector("cropper-image");
    //         if (cropperImage) {
    //             const finalRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
    //             const finalScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1;
    //             const finalScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1;
    //
    //             if (finalRotate !== 0 || finalScaleX !== 1 || finalScaleY !== 1) {
    //                 // Translate center coordinates to pivot the image array correctly on final save
    //                 ctx.translate(canvas.width / 2, canvas.height / 2);
    //                 ctx.scale(finalScaleX, finalScaleY);
    //                 ctx.rotate((finalRotate * Math.PI) / 180);
    //                 ctx.translate(-canvas.width / 2, -canvas.height / 2);
    //             }
    //         }
    //         //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //
    //         //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //         // 1.Fine-Tuned Brightness & Contrast Calibration Controls
    //         // Update inside your applyModifications() try block:
    //         const brightness = this.brightnessSliderTarget.value;
    //         const contrast = this.contrastSliderTarget.value;
    //
    //         // Inject combined values right into the canvas drawing engine context before generating blobs
    //         tempCtx.filter = `${filterMap[filterValue] || "none"} brightness(${brightness}%) contrast(${contrast}%)`;
    //         //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //         // Locate this exact section inside your applyModifications() method and modify as follows:
    //         const cropperSelection = this.element.querySelector("cropper-selection")
    //         if (!cropperSelection) return
    //
    //         // FIXED FOR V2 DYNAMIC RATIOS: Let Cropper calculate dimensions automatically based on selected aspect ratio box
    //         const canvas = await cropperSelection.$toCanvas({
    //             maxWidth: 2000,
    //             maxHeight: 2000
    //         })
    //
    //         // Safely reference our filterSelect target element properties
    //         const filterValue = this.hasFilterSelectTarget ? this.filterSelectTarget.value : "none"
    //
    //         if (!canvas) return
    //
    //         const ctx = canvas.getContext("2d")
    //
    //         // =======================================================================
    //         // pixel matrix into canvas file
    //         if (filterValue !== "none") {
    //             const tempCanvas = document.createElement("canvas");
    //             tempCanvas.width = canvas.width;
    //             tempCanvas.height = canvas.height;
    //             const tempCtx = tempCanvas.getContext("2d");
    //
    //
    //
    //
    //             // Compile standard filter configurations strings
    //             const activeBaseFilter = filterMap[filterValue] || "";
    //             tempCtx.filter = `${activeBaseFilter} brightness(${brightness}%) contrast(${contrast}%)`.trim();
    //
    //             // Repaint the base cropped image onto the temp buffer layer
    //             tempCtx.drawImage(canvas, 0, 0);
    //
    //             // =======================================================================
    //             // NEW HALFTONE INTEGRATION INTERCEPT LOOP
    //             // If the user selected the halftone option, intercept and burn pixels directly
    //             if (filterValue === "comic-halftone") {
    //                 this.applyComicHalftone(tempCanvas, tempCtx);
    //             }
    //             // =======================================================================
    //
    //             // Wipe out original clean canvas context frames data
    //             ctx.clearRect(0, 0, canvas.width, canvas.height);
    //
    //             // Draw the final manipulated temp canvas data back onto primary canvas file
    //             ctx.drawImage(tempCanvas, 0, 0);
    //
    //
    //
    //
    //
    //             // passing details CSS-matrix of filtration to context of  Canvas API [POST]
    //             const filterMap = {
    //                 "vintage": "sepia(40%) saturate(120%) contrast(90%) hue-rotate(-10deg)",
    //                 "parchment": "sepia(30%) contrast(95%) brightness(105%) saturate(80%)",
    //                 "faded-log": "brightness(130%) contrast(85%) saturate(70%)",
    //                 "dim-manuscript": "brightness(75%) contrast(110%) saturate(60%)",
    //                 "high-contrast-monorail": "grayscale(100%) contrast(200%) brightness(90%)",
    //                 "night-vision": "sepia(100%) hue-rotate(85deg) saturate(200%) contrast(140%)",
    //                 "thermal-sensor": "invert(100%) hue-rotate(180deg) saturate(300%) contrast(150%)",
    //                 "amber-cathode": "grayscale(100%) sepia(100%) hue-rotate(5deg) saturate(400%) contrast(120%) brightness(95%)",
    //                 "cyan-laser": "grayscale(100%) sepia(100%) hue-rotate(145deg) saturate(350%) contrast(120%)",
    //                 "glitch-ghost": "invert(80%) hue-rotate(90deg) contrast(150%) saturate(50%)",
    //                 "overclocked": "saturate(300%) contrast(130%) brightness(105%)",
    //                 "dark-matter": "hue-rotate(30deg) brightness(85%) contrast(90%) saturate(50%)",
    //                 "solar-flare": "contrast(180%) invert(15%) hue-rotate(-30deg) saturate(200%)",
    //                 "neon-cyber": "hue-rotate(290deg) saturate(180%) contrast(125%)",
    //                 "toxic-waste": "hue-rotate(60deg) saturate(250%) contrast(160%) brightness(110%)",
    //                 "martian-soil": "sepia(100%) hue-rotate(-30deg) saturate(250%) contrast(110%)",
    //                 "deep-space": "hue-rotate(200deg) brightness(80%) contrast(120%) saturate(60%)",
    //                 "aurora": "hue-rotate(100deg) saturate(160%) brightness(95%) contrast(115%)",
    //                 "supernova": "brightness(180%) contrast(150%) saturate(140%)",
    //                 "pulsar": "contrast(150%) brightness(60%) saturate(110%) hue-rotate(45deg)",
    //                 "golden-ratio": "sepia(100%) hue-rotate(15deg) saturate(250%) contrast(105%) brightness(105%)",
    //                 "quicksilver": "grayscale(100%) brightness(115%) contrast(130%)",
    //                 "copper-rust": "sepia(80%) hue-rotate(110deg) saturate(200%) contrast(110%)",
    //                 "charcoal-ash": "grayscale(100%) brightness(50%) contrast(140%)",
    //                 "amethyst": "sepia(100%) hue-rotate(240deg) saturate(250%) contrast(115%)",
    //                 // Basic standarts
    //                 "grayscale": "grayscale(100%)",
    //                 "sepia": "sepia(100%)",
    //                 "invert": "invert(100%)",
    //                 "saturate-150": "saturate(170%)",
    //                 // Optical
    //                 "blueprint-cyan": "contrast(140%) brightness(95%) sepia(100%) hue-rotate(160deg) saturate(250%) opacity(90%)",
    //                 "xray-spectre": "grayscale(100%) invert(100%) brightness(110%) contrast(150%)",
    //                 "high-shadows": "contrast(160%) brightness(85%) saturate(90%)",
    //                 "monochrome-glow": "grayscale(100%) brightness(120%) contrast(130%) sepia(100%) hue-rotate(75deg) saturate(300%)",
    //                 "high-dynamic": "contrast(135%) saturate(160%) brightness(110%)",
    //                 // Optical
    //                 "comic-halftone": "grayscale(100%) contrast(300%) brightness(100%) opacity(95%)"
    //             };
    //
    //             tempCtx.filter = filterMap[filterValue] || "none";
    //             tempCtx.drawImage(canvas, 0, 0);
    //
    //             ctx.clearRect(0, 0, canvas.width, canvas.height);
    //             ctx.drawImage(tempCanvas, 0, 0);
    //         }
    //         // =======================================================================
    //
    //         // Your existing watermark drawing sequence continues cleanly right underneath:
    //         ctx.font = "bold 14px monospace"
    //         ctx.fillStyle = "rgba(6, 182, 212, 0.4)"
    //         ctx.fillText("// OBJECTSPACE_SECURE_COGNITIVE_REVISION", 24, canvas.height - 24)
    //
    //         // Convert canvas map to high-fidelity DataURL blob string data payload
    //         const dataUrl = canvas.toDataURL("image/jpeg", 0.92)
    //
    //         // Inject the modified base64 data stream straight into a preview thumbnail card element
    //         this.previewTarget.innerHTML = `
    //             <div class="relative w-full h-full aspect-[21/7] md:aspect-square">
    //               <img src="${dataUrl}" class="w-full h-full object-cover rounded-xl" />
    //               <span class="absolute top-2 left-2 bg-emerald-500/90 text-white font-mono text-[8px] px-1.5 py-0.5 rounded border border-emerald-400 font-black tracking-widest uppercase animate-pulse">✓ Ready to Inscribe</span>
    //             </div>
    //         `
    //
    //         // Generate a file transmission blob to override the native file selection parameters array input structure
    //         canvas.toBlob((blob) => {
    //             const croppedFile = new File([blob], "algorithm_cover_processed.jpg", { type: "image/jpeg" })
    //
    //             // Programmatically patch the file array parameter list inside your actual file field tag
    //             const dataTransfer = new DataTransfer()
    //             dataTransfer.items.add(croppedFile)
    //             this.inputTarget.files = dataTransfer.files
    //
    //             // Gracefully collapse the cropper tool frame workspace overlay array
    //             this.cropperContainerTarget.classList.add("hidden")
    //         }, "image/jpeg", 0.92)
    //
    //     } catch (error) {
    //         console.error("Error executing dynamic canvas crop parameters pipeline:", error)
    //     }
    // }


    // B. Commit & Seal current parameters into standard form upload parameters
    async applyModifications(event) {
        event.preventDefault()
        if (!this.cropper) return

        try {
            // 1. Locate Cropper v2 selection box workspace node
            const cropperSelection = this.element.querySelector("cropper-selection")
            if (!cropperSelection) return

            // 2. Generate clean baseline crop box canvas file mapping properties
            const canvas = await cropperSelection.$toCanvas({
                maxWidth: 2000,
                maxHeight: 2000
            })
            if (!canvas) return

            const ctx = canvas.getContext("2d")

            // 3. Read interactive controls state properties layout adjustments
            const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100
            const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100
            const activeFilterValue = this.hasFilterSelectTarget ? this.filterSelectTarget.value : "none"
            const activeComicStyle = this.hasComicStyleSelectTarget ? this.comicStyleSelectTarget.value : "none"

            // 4. Geometry Orientation Matrix Transformations (Rotation & Flips Burn Loop)
            const cropperImage = this.element.querySelector("cropper-image")
            if (cropperImage) {
                const finalRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0
                const finalScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1
                const finalScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1

                if (finalRotate !== 0 || finalScaleX !== 1 || finalScaleY !== 1) {
                    const transCanvas = document.createElement("canvas")
                    transCanvas.width = canvas.width
                    transCanvas.height = canvas.height
                    const transCtx = transCanvas.getContext("2d")

                    // Shift tracking space origin points straight around center core pivot
                    transCtx.translate(canvas.width / 2, canvas.height / 2)
                    transCtx.scale(finalScaleX, finalScaleY)
                    transCtx.rotate((finalRotate * Math.PI) / 180)
                    transCtx.translate(-canvas.width / 2, -canvas.height / 2)

                    transCtx.drawImage(canvas, 0, 0)

                    ctx.clearRect(0, 0, canvas.width, canvas.height)
                    ctx.drawImage(transCanvas, 0, 0)
                }
            }

            // 5. Complete Dictionaries Synchronized Mapping Layout properties
            const filterMap = {
                "none": "", "grayscale": "grayscale(100%)", "sepia": "sepia(100%)", "invert": "invert(100%)", "saturate-150": "saturate(1.7)",
                "vintage": "sepia(40%) saturate(120%) contrast(90%) hue-rotate(-10deg)", "parchment": "sepia(30%) contrast(95%) brightness(105%) saturate(80%)",
                "faded-log": "brightness(130%) contrast(85%) saturate(70%)", "dim-manuscript": "brightness(75%) contrast(110%) saturate(60%)",
                "high-contrast-monorail": "grayscale(100%) contrast(200%) brightness(90%)",
                "night-vision": "sepia(100%) hue-rotate(85deg) saturate(200%) contrast(140%)",
                "thermal-sensor": "invert(100%) hue-rotate(180deg) saturate(300%) contrast(150%)",
                "amber-cathode": "grayscale(100%) sepia(100%) hue-rotate(5deg) saturate(400%) contrast(120%) brightness(95%)",
                "cyan-laser": "grayscale(100%) sepia(100%) hue-rotate(145deg) saturate(350%) contrast(120%)",
                "glitch-ghost": "invert(80%) hue-rotate(90deg) contrast(150%) saturate(50%)",
                "overclocked": "saturate(300%) contrast(130%) brightness(105%)",
                "dark-matter": "hue-rotate(30deg) brightness(85%) contrast(90%) saturate(50%)",
                "solar-flare": "contrast(180%) invert(15%) hue-rotate(-30deg) saturate(200%)",
                "neon-cyber": "hue-rotate(290deg) saturate(180%) contrast(125%)",
                "toxic-waste": "hue-rotate(60deg) saturate(250%) contrast(160%) brightness(110%)",
                "martian-soil": "sepia(100%) hue-rotate(-30deg) saturate(250%) contrast(110%)",
                "deep-space": "hue-rotate(200deg) brightness(80%) contrast(120%) saturate(60%)",
                "aurora": "hue-rotate(100deg) saturate(160%) brightness(95%) contrast(115%)",
                "supernova": "brightness(180%) contrast(150%) saturate(140%)",
                "pulsar": "contrast(150%) brightness(60%) saturate(110%) hue-rotate(45deg)",
                "golden-ratio": "sepia(100%) hue-rotate(15deg) saturate(250%) contrast(105%) brightness(105%)",
                "quicksilver": "grayscale(100%) brightness(115%) contrast(130%)",
                "copper-rust": "sepia(80%) hue-rotate(110deg) saturate(200%) contrast(110%)",
                "charcoal-ash": "grayscale(100%) brightness(50%) contrast(140%)",
                "amethyst": "sepia(100%) hue-rotate(240deg) saturate(250%) contrast(115%)",
                "blueprint-cyan": "contrast(140%) brightness(95%) sepia(100%) hue-rotate(160deg) saturate(250%) opacity(90%)",
                "xray-spectre": "grayscale(100%) invert(100%) brightness(110%) contrast(150%)",
                "high-shadows": "contrast(160%) brightness(85%) saturate(90%)",
                "monochrome-glow": "grayscale(100%) brightness(120%) contrast(130%) sepia(100%) hue-rotate(75deg) saturate(300%)",
                "high-dynamic": "contrast(135%) saturate(160%) brightness(110%)",
                "noir-graphic-novel": "grayscale(100%) contrast(500%) brightness(90%) drop-shadow(2px 2px 0px #000000)"
            }

            const comicStylesMap = {
                "none": "",
                "pop-dots": "contrast(350%) brightness(100%) saturate(150%) hue-rotate(-5deg)",
                "ink-sketch": "grayscale(100%) contrast(500%) brightness(95%)",
                "oil-comic": "saturate(250%) contrast(140%) brightness(105%) opacity(95%)",
                "vintage-print": "sepia(30%) contrast(120%) brightness(98%) saturate(90%)",
                "cyber-punk": "hue-rotate(290deg) saturate(400%) contrast(160%) brightness(110%)",
                "charcoal-novel": "grayscale(100%) brightness(120%) contrast(180%)",
                "noir-shadows": "grayscale(100%) contrast(600%) brightness(80%)",
                "acid-glow": "hue-rotate(65deg) saturate(500%) contrast(200%) brightness(115%)",
                "void-abyss": "hue-rotate(190deg) contrast(150%) brightness(75%) saturate(80%)",
                "quantum-glitch": "invert(100%) hue-rotate(180deg) contrast(400%) saturate(0%) brightness(130%)"
            }

            // Decide filter preset visibility hierarchy logic tracking dependencies smoothly
            let chosenBaseMatrix = ""
            if (activeComicStyle !== "none") {
                chosenBaseMatrix = comicStylesMap[activeComicStyle] || ""
            } else {
                chosenBaseMatrix = filterMap[activeFilterValue] || ""
            }

            // 6. Hard-bake exposure pixels matrix via secure proxy layer context
            const hasCustomStyles = chosenBaseMatrix !== "" || parseInt(brightness) !== 100 || parseInt(contrast) !== 100

            if (hasCustomStyles) {
                const tempCanvas = document.createElement("canvas")
                tempCanvas.width = canvas.width
                tempCanvas.height = canvas.height
                const tempCtx = tempCanvas.getContext("2d")

                // CRITICAL FIX: Ensure tempCtx configurations execution order is synchronous
                tempCtx.filter = `${chosenBaseMatrix} brightness(${brightness}%) contrast(${contrast}%)`.trim()
                tempCtx.drawImage(canvas, 0, 0)

                // Intercept execution process loop to safely process comic dot matrix structures
                if (activeFilterValue === "comic-halftone" && typeof this.applyComicHalftone === "function") {
                    this.applyComicHalftone(tempCanvas, tempCtx)
                }

                ctx.clearRect(0, 0, canvas.width, canvas.height)
                ctx.drawImage(tempCanvas, 0, 0)
            }

            // 7. Inject high-fidelity technical textual watermark overlay structures properties
            ctx.font = "bold 14px monospace"
            ctx.fillStyle = "rgba(6, 182, 212, 0.4)"
            ctx.fillText("// OBJECTSPACE_SECURE_COGNITIVE_REVISION", 24, canvas.height - 24)

            // 8. Output complete payload straight onto user preview card component element layout grids
            const dataUrl = canvas.toDataURL("image/jpeg", 0.92)

            if (this.hasPreviewTarget) {
                this.previewTarget.innerHTML = `
                    <div class="relative w-full h-full flex justify-center items-center bg-slate-900 rounded-xl overflow-hidden">
                      <img src="${dataUrl}" class="w-full h-full object-contain rounded-xl" />
                      <span class="absolute top-2 left-2 bg-emerald-500/90 text-white font-mono text-[8px] px-1.5 py-0.5 rounded border border-emerald-400 font-black tracking-widest uppercase animate-pulse">✓ Ready</span>
                    </div>    `
            }

            // 9. Compress canvas back into a clean transmission binary file blob packet
            canvas.toBlob((blob) => {
                if (!blob) return
                const croppedFile = new File([blob], "algorithm_cover_processed.jpg", { type: "image/jpeg" })

                const dataTransfer = new DataTransfer()
                dataTransfer.items.add(croppedFile)

                if (this.hasInputTarget) {
                    this.inputTarget.files = dataTransfer.files
                }

                // Gracefully lock out overlay layout windows worksp
                // Programmatically dispatch a native change event so Rails UJS / Turbo knows the file input was updated
                this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))

                // Gracefully collapse workspace editor container view layer grids
                if (this.hasCropperContainerTarget) {
                    this.cropperContainerTarget.classList.add("hidden")
                }

                // Explicitly clear original memory caches stream to avoid leaks
                this.originalUploadedImageBase64 = null
                console.log("Transmission array patched: Algorithm cover payload successfully locked into form matrix.")
            }, "image/jpeg", 0.92)

        } catch (error) {
            console.error("Error executing dynamic canvas crop parameters pipeline:", error)
        }
    }



    /**
     * Live Preview Filter Matrix Mapping (Fixed Scope for Cropper v2)
     * Connected to: change->algorithm_cover_upload#applyFilter
     */
    applyFilter(event) {
        if (!this.cropper) return;
        const filterValue = event.target.value;
        this.filterType = filterValue; // Update instance tracking state

        // Target the explicit CropperJS v2 web component canvas block
        const cropperCanvas = this.element.querySelector("cropper-canvas");

        if (!cropperCanvas) {
            console.error("Cannot apply filter: <cropper-canvas> element layout empty.");
            return;
        }

        // Reset styling filters back to clean defaults
        cropperCanvas.style.filter = "none";

        // =======================================================================
        // LIVE REALTIME HALFTONE INJECTION INTERCEPT (FIXED SCOPE)
        // =======================================================================
        if (filterValue === "comic-halftone") {
            const cropperSelection = this.element.querySelector("cropper-selection");
            if (cropperSelection) {
                // Asynchronously capture the current visible viewport slice box
                cropperSelection.$toCanvas({ maxWidth: 1000, maxHeight: 1000 }).then((canvas) => {
                    if (!canvas) return;
                    const ctx = canvas.getContext("2d");

                    // Fire your custom high-computational dot matrix method live!
                    this.applyComicHalftone(canvas, ctx);

                    // Inject the processed dot matrix data URL back onto the display layer node
                    const processedDataUrl = canvas.toDataURL("image/png");

                    // CRITICAL FIX: Fetch the inner nodes directly inside the promise scope block
                    const innerCanvas = this.element.querySelector("cropper-canvas");
                    const innerImage = this.element.querySelector("cropper-image");

                    if (innerImage && innerCanvas) {
                        innerCanvas.style.filter = "none";
                        // Update the internal image element tag source to force instant view redraws
                        if (this.hasCropImageTarget) {
                            this.cropImageTarget.src = processedDataUrl;
                        }
                    }
                });
            }
            return; // Exit early since halftone handles its own layout drawings
        }
        // =======================================================================

        // Standard CSS-matrix effects filters dictionary mapping configurations
        const filterMap = {
            "none": "none",
            "grayscale": "grayscale(100%)",
            "sepia": "sepia(100%)",
            "invert": "invert(100%)",
            "saturate-150": "saturate(1.7)",

            // Archival
            "vintage": "sepia(40%) saturate(120%) contrast(90%) hue-rotate(-10deg)",
            "parchment": "sepia(30%) contrast(95%) brightness(105%) saturate(80%)",
            "faded-log": "brightness(130%) contrast(85%) saturate(70%)",
            "dim-manuscript": "brightness(75%) contrast(110%) saturate(60%)",
            "high-contrast-monorail": "grayscale(100%) contrast(200%) brightness(90%)",

            // Technical Spectrometry
            "night-vision": "sepia(100%) hue-rotate(85deg) saturate(200%) contrast(140%)",
            "thermal-sensor": "invert(100%) hue-rotate(180deg) saturate(300%) contrast(150%)",
            "amber-cathode": "grayscale(100%) sepia(100%) hue-rotate(5deg) saturate(400%) contrast(120%) brightness(95%)",
            "cyan-laser": "grayscale(100%) sepia(100%) hue-rotate(145deg) saturate(350%) contrast(120%)",
            "glitch-ghost": "invert(80%) hue-rotate(90deg) contrast(150%) saturate(50%)",

            // Telemetry & Alchemy Fields
            "overclocked": "saturate(300%) contrast(130%) brightness(105%)",
            "dark-matter": "hue-rotate(30deg) brightness(85%) contrast(90%) saturate(50%)",
            "solar-flare": "contrast(180%) invert(15%) hue-rotate(-30deg) saturate(200%)",
            "neon-cyber": "hue-rotate(290deg) saturate(180%) contrast(125%)",
            "toxic-waste": "hue-rotate(60deg) saturate(250%) contrast(160%) brightness(110%)",

            // Extra-Terrestrial Cartography
            "martian-soil": "sepia(100%) hue-rotate(-30deg) saturate(250%) contrast(110%)",
            "deep-space": "hue-rotate(200deg) brightness(80%) contrast(120%) saturate(60%)",
            "aurora": "hue-rotate(100deg) saturate(160%) brightness(95%) contrast(115%)",
            "supernova": "brightness(180%) contrast(150%) saturate(140%)",
            "pulsar": "contrast(150%) brightness(60%) saturate(110%) hue-rotate(45deg)",

            // Alchemy & Optical Analysis
            "golden-ratio": "sepia(100%) hue-rotate(15deg) saturate(250%) contrast(105%) brightness(105%)",
            "quicksilver": "grayscale(100%) brightness(115%) contrast(130%)",
            "copper-rust": "sepia(80%) hue-rotate(110deg) saturate(200%) contrast(110%)",
            "charcoal-ash": "grayscale(100%) brightness(50%) contrast(140%)",
            "amethyst": "sepia(100%) hue-rotate(240deg) saturate(250%) contrast(115%)",
            "blueprint-cyan": "contrast(140%) brightness(95%) sepia(100%) hue-rotate(160deg) saturate(250%) opacity(90%)",
            "xray-spectre": "grayscale(100%) invert(100%) brightness(110%) contrast(150%)",
            "high-shadows": "contrast(160%) brightness(85%) saturate(90%)",
            "monochrome-glow": "grayscale(100%) brightness(120%) contrast(130%) sepia(100%) hue-rotate(75deg) saturate(300%)",
            "high-dynamic": "contrast(135%) saturate(160%) brightness(110%)",

            // New
            "noir-graphic-novel": "grayscale(100%) contrast(500%) brightness(90%) drop-shadow(2px 2px 0px #000000)"
        };

        // Inject filter matrices along with runtime custom slider settings
        const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100;
        const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100;

        cropperCanvas.style.filter = `${filterMap[filterValue] || "none"} brightness(${brightness}%) contrast(${contrast}%)`;
        console.log(`Live screen spectrometry filter successfully applied: ${filterValue}`);
    }



    discardModifications(event) {
        event.preventDefault()
        if (this.cropper) {
            this.cropper.destroy()
            this.cropper = null
        }
        this.cropperContainerTarget.classList.add("hidden")
        this.inputTarget.value = ""
    }


    // Add this unified tuning calibration handler method:
    tuneImageAdjustments() {
        const cropperCanvas = this.element.querySelector("cropper-canvas");
        if (!cropperCanvas) return;

        // Read the granular slider node levels values natively
        const brightness = this.brightnessSliderTarget.value;
        const contrast = this.contrastSliderTarget.value;

        // Print values live to the tracking text labels badges
        this.brightnessValTarget.textContent = `${brightness}%`;
        this.contrastValTarget.textContent = `${contrast}%`;

        // Isolate whatever baseline drop-down preset filter is active
        const activeFilterValue = this.hasFilterSelectTarget ? this.filterSelectTarget.value : "none";
        let baseCssFilter = "none";

        // Re-evaluate your baseline filter selection to combine them with custom slider values smoothly
        if (activeFilterValue === "grayscale") baseCssFilter = "grayscale(100%)";
        if (activeFilterValue === "sepia") baseCssFilter = "sepia(100%)";
        if (activeFilterValue === "invert") baseCssFilter = "invert(100%)";
        if (activeFilterValue === "saturate-150") baseCssFilter = "saturate(1.7)";

        // Apply combined technical CSS matrix filter layout directly onto the Cropper v2 drawing canvas workspace
        cropperCanvas.style.filter = `${baseCssFilter === "none" ? "" : baseCssFilter} brightness(${brightness}%) contrast(${contrast}%)`;
        console.log(`Image calibrated: Brightness(${brightness}%) | Contrast(${contrast}%)`);
    }

    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js
    rotateLeft(event) {
        event.preventDefault();
        const cropperCanvas = this.element.querySelector("cropper-canvas");
        const cropperImage = this.element.querySelector("cropper-image");
        if (cropperCanvas && cropperImage) {
            // Read from current attribute state layer or initialize at zero
            const currentRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
            const newRotate = currentRotate - 90;

            // 1. Maintain tracking states on elements for form committal logs
            cropperImage.setAttribute("rotate", newRotate);
            cropperImage.rotate = newRotate;

            // 2. CRUCIAL FOR V2 UI: Force the CSS Variable on the canvas wrapper to trigger instant redraws
            cropperCanvas.style.setProperty("--cropper-rotate", `${newRotate}deg`);

            // 3. Dispatch internal update flag notification to sync crop box positioning
            if (typeof cropperCanvas.$transform === "function") {
                cropperCanvas.$transform();
            }
            console.log(`Canvas rotated to exact degree: ${newRotate}`);
        }
    }

    rotateRight(event) {
        event.preventDefault();
        const cropperCanvas = this.element.querySelector("cropper-canvas");
        const cropperImage = this.element.querySelector("cropper-image");
        if (cropperCanvas && cropperImage) {
            const currentRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
            const newRotate = currentRotate + 90;

            cropperImage.setAttribute("rotate", newRotate);
            cropperImage.rotate = newRotate;

            cropperCanvas.style.setProperty("--cropper-rotate", `${newRotate}deg`);

            if (typeof cropperCanvas.$transform === "function") {
                cropperCanvas.$transform();
            }
            console.log(`Canvas rotated to exact degree: ${newRotate}`);
        }
    }

    flipHorizontal(event) {
        event.preventDefault();
        const cropperCanvas = this.element.querySelector("cropper-canvas");
        const cropperImage = this.element.querySelector("cropper-image");
        if (cropperCanvas && cropperImage) {
            const currentScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1;
            const newScaleX = currentScaleX === 1 ? -1 : 1;

            cropperImage.setAttribute("scale-x", newScaleX);
            cropperImage.scaleX = newScaleX;

            // CRUCIAL FOR V2 UI: Apply scale-x variable transformation directly on canvas layout layer
            cropperCanvas.style.setProperty("--cropper-scale-x", newScaleX);

            if (typeof cropperCanvas.$transform === "function") {
                cropperCanvas.$transform();
            }
            console.log(`Canvas flipped horizontally. New scale-x: ${newScaleX}`);
        }
    }

    flipVertical(event) {
        event.preventDefault();
        const cropperCanvas = this.element.querySelector("cropper-canvas");
        const cropperImage = this.element.querySelector("cropper-image");
        if (cropperCanvas && cropperImage) {
            const currentScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1;
            const newScaleY = currentScaleY === 1 ? -1 : 1;

            cropperImage.setAttribute("scale-y", newScaleY);
            cropperImage.scaleY = newScaleY;

            // CRUCIAL FOR V2 UI: Apply scale-y variable transformation directly on canvas layout layer
            cropperCanvas.style.setProperty("--cropper-scale-y", newScaleY);

            if (typeof cropperCanvas.$transform === "function") {
                cropperCanvas.$transform();
            }
            console.log(`Canvas flipped vertically. New scale-y: ${newScaleY}`);
        }
    }

    // Add this method into your Stimulus controller class architecture:
    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js

    changeAspectRatio(event) {
        event.preventDefault();

        // Extract the selected target mathematical aspect ratio coefficient float from the button data layer attribute
        const targetRatio = parseFloat(event.currentTarget.dataset.ratio);

        // In Cropper.js v2, the aspect ratio boundary is tracked directly inside the <cropper-selection> web component
        const cropperSelection = this.element.querySelector("cropper-selection");

        if (cropperSelection) {
            // Apply the new geometric parameter value natively
            cropperSelection.aspectRatio = targetRatio;
            console.log(`Cropping mask aspect-ratio switched cleanly to coefficient parameter: ${targetRatio}`);

            // UI GAMIFICATION TAB POLISHING: Switch active CSS classes to highlight selection
            const buttons = event.currentTarget.parentElement.querySelectorAll("button");
            buttons.forEach(btn => {
                // Clear active layout styles
                btn.className = "px-3 py-1.5 text-[11px] font-mono font-black rounded-lg transition-all cursor-pointer transform active:scale-95 text-slate-600 hover:bg-slate-50";
            });

            // Inject primary active theme state parameters back into selection button node
            event.currentTarget.className = "px-3 py-1.5 bg-white border border-slate-200 text-[11px] font-mono font-black text-cyan-600 rounded-lg shadow-sm transition-all cursor-pointer transform active:scale-95";
        } else {
            console.error("Failed to re-configure aspect parameters: <cropper-selection> component not found.");
        }
    }

    /**
     * 2. Comprehensive Scaling Drawing Loop
     */
    drawCanvas() {
        if (!this.hasCanvasTarget || !this.coverImageInstance) {
            console.error("Critical Runtime Stop: Canvas target or image memory profile missing.")
            return
        }

        const canvas = this.canvasTarget
        const ctx = canvas.getContext("2d")

        // Force aspect container box limits configurations parameters updates
        const currentAspectRatio = parseFloat(this.targetAspectRatio) || 3
        const containerWidth = 800
        const calculatedHeight = containerWidth / currentAspectRatio

        // Explicitly update pixel layout mapping grids (wipes out old states data layers textures)
        canvas.width = containerWidth
        canvas.height = calculatedHeight

        // Clear frame matrix trace artifacts layout properties
        ctx.clearRect(0, 0, canvas.width, canvas.height)
        ctx.save()

        // Compile filter adjustments modifications (Exposure matrix chains tracking)
        let filtersString = `brightness(${this.brightness}%) contrast(${this.contrast}%) `
        filtersString += this.getMatrixFilterCSS()
        ctx.filter = filtersString.trim()

        // 1. Shift context coordinate systems space origin point directly to center of viewport workspace
        ctx.translate(canvas.width / 2, canvas.height / 2)

        // 2. Apply absolute orientation geometry updates (Flips and Rotations)
        ctx.scale(this.flipH, this.flipV)
        ctx.rotate((this.rotationAngle * Math.PI) / 180)

        // 3. Calculate baseline image dimensions to fit perfectly inside the canvas boundary
        let fitWidth = canvas.width
        let fitHeight = canvas.width * (this.coverImageInstance.height / this.coverImageInstance.width)

        // Re-balance aspect ratio bounds if vertical bounds are restricted
        if (fitHeight < canvas.height) {
            fitHeight = canvas.height
            fitWidth = canvas.height * (this.coverImageInstance.width / this.coverImageInstance.height)
        }

        // 4. CRITICAL FIX: Multiply base sizes by the scale variable to force it to enlarge and shrink
        const zoomMultiplier = parseFloat(this.currentScale) || 1.0
        let finalRenderWidth = fitWidth * zoomMultiplier
        let finalRenderHeight = fitHeight * zoomMultiplier

        // 5. Paint image centered directly over the transformation origin point
        ctx.drawImage(
            this.coverImageInstance,
            -finalRenderWidth / 2,
            -finalRenderHeight / 2,
            finalRenderWidth,
            finalRenderHeight
        )

        ctx.restore()
        console.log(`Absolute canvas zoom safely mapped to: ${Math.round(zoomMultiplier * 100)}%`)
    }



    /**
     * Hardware-Independent Comic & Adventure Art Style Transformation Engine
     * Bypasses broken WebGL sandbox flags to execute transformations via CSS layout matrices.
     * Connected to: change->algorithm_cover_upload#applyComicStyle
     */
    applyComicStyle(event) {
        if (!this.cropper) return;
        const styleSelected = event.target.value;
        console.log(`Executing bulletproof comic design shift parameter: [${styleSelected}]`);

        // Target the outer web component layout engine generated by CropperJS v2
        const cropperCanvas = this.element.querySelector("cropper-canvas");
        if (!cropperCanvas) {
            console.error("Art Engine Error: <cropper-canvas> element node could not be targeted.");
            return;
        }

        // Reset the legacy filter select dropdown choice so they do not overlap styles
        if (this.hasFilterSelectTarget) {
            this.filterSelectTarget.value = "none";
        }

        // Clear out baseline styles completely
        cropperCanvas.style.filter = "none";

        // Read active continuous calibration range sliders parameters values dynamically
        const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100;
        const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100;

        // 10 ADVENTURE & COMIC ART MAP DICTIONARY
        const comicStylesMap = {
            "none": "",

            // 01. Retro Pop-Art: Pure binary ink shading typical of comic printing plates
            "pop-dots": "contrast(350%) brightness(100%) saturate(150%) hue-rotate(-5deg)",

            // 02. Graphic Novel Ink Sketch: Stark black and white outline boundaries
            "ink-sketch": "grayscale(100%) contrast(500%) brightness(95%)",

            // 03. Manga Cel Shading: Ultra-saturated colors with heavy ink depth properties
            "oil-comic": "saturate(250%) contrast(140%) brightness(105%) opacity(95%)",

            // 04. 1950s Newspaper Comic: Muted, warm bleached textures
            "vintage-print": "sepia(30%) contrast(120%) brightness(98%) saturate(90%)",

            // 05. Cyberpunk Neon Edge: Acid fluorescent pinks and teals
            "cyber-punk": "hue-rotate(290deg) saturate(400%) contrast(160%) brightness(110%)",

            // 06. Charcoal Graphic Novel: Charcoal smudge look using desaturated high-exposure shadows
            "charcoal-novel": "grayscale(100%) brightness(120%) contrast(180%)",

            // 07. Sin City Noir: Zero mid-tones, absolute dark shadows ink mapping
            "noir-shadows": "grayscale(100%) contrast(600%) brightness(80%)",

            // 08. Toxic Waste Radiance: High-density nuclear phosphor green overlay
            "acid-glow": "hue-rotate(65deg) saturate(500%) contrast(200%) brightness(115%)",

            // 09. Space Odyssey Abyss: Deep vacuum shadow layers with cold blue balance wash
            "void-abyss": "hue-rotate(190deg) contrast(150%) brightness(75%) saturate(80%)",

            // 10. Quantum Laser Glitch: High exposure scan matrix terminal look
            "quantum-glitch": "invert(100%) hue-rotate(180deg) contrast(400%) saturate(0%) brightness(130%)"
        };

        // Extract your selection filter string property rules
        const activeBaseStyle = comicStylesMap[styleSelected] || "";

        // Combine the custom comic matrix style with your continuous calibration levels dynamically
        cropperCanvas.style.filter = `${activeBaseStyle} brightness(${brightness}%) contrast(${contrast}%)`.trim();

        console.log(`Artistic style '${styleSelected}' updated live via CSS matrix.`);
    }


    /**
     * Realtime Brightness/Contrast Adjustment Interface Slider Triggers
     * Connected to: input->algorithm_cover_upload#tuneImageAdjustments
     */
    tuneImageAdjustments() {
        const cropperCanvas = this.element.querySelector("cropper-canvas");
        if (!cropperCanvas) return;

        // Read the granular slider node levels values natively
        const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100;
        const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100;

        // Update live screen text label badge elements
        if (this.hasBrightnessValTarget) this.brightnessValTarget.textContent = `${brightness}%`;
        if (this.hasContrastValTarget) this.contrastValTarget.textContent = `${contrast}%`;

        // Check which dropdown style choice parameter is active right now
        const activeFilterValue = this.hasFilterSelectTarget ? this.filterSelectTarget.value : "none";
        const activeComicStyle = this.hasComicStyleSelectTarget ? this.comicStyleSelectTarget.value : "none";

        // Base Filter Fallback Map Dictionary
        const filterMap = {
            "none": "", "grayscale": "grayscale(100%)", "sepia": "sepia(100%)", "invert": "invert(100%)", "saturate-150": "saturate(1.7)",
            "vintage": "sepia(40%) saturate(120%) contrast(90%) hue-rotate(-10deg)", "parchment": "sepia(30%) contrast(95%) brightness(105%) saturate(80%)",
            "faded-log": "brightness(130%) contrast(85%) saturate(70%)", "dim-manuscript": "brightness(75%) contrast(110%) saturate(60%)",
            "high-contrast-monorail": "grayscale(100%) contrast(200%) brightness(90%)"
        };

        // Comic Book Style Fallback Map Dictionary
        const comicStylesMap = {
            "none": "",
            "pop-dots": "contrast(350%) brightness(100%) saturate(150%) hue-rotate(-5deg)",
            "ink-sketch": "grayscale(100%) contrast(500%) brightness(95%)",
            "oil-comic": "saturate(250%) contrast(140%) brightness(105%) opacity(95%)",
            "vintage-print": "sepia(30%) contrast(120%) brightness(98%) saturate(90%)",
            "cyber-punk": "hue-rotate(290deg) saturate(400%) contrast(160%) brightness(110%)",
            "charcoal-novel": "grayscale(100%) brightness(120%) contrast(180%)",
            "noir-shadows": "grayscale(100%) contrast(600%) brightness(80%)",
            "acid-glow": "hue-rotate(65deg) saturate(500%) contrast(200%) brightness(115%)",
            "void-abyss": "hue-rotate(190deg) contrast(150%) brightness(75%) saturate(80%)",
            "quantum-glitch": "invert(100%) hue-rotate(180deg) contrast(400%) saturate(0%) brightness(130%)"
        };

        // Isolate which overlay structure currently takes priority tracking
        let chosenBaseMatrix = "";
        if (activeComicStyle !== "none") {
            chosenBaseMatrix = comicStylesMap[activeComicStyle] || "";
        } else {
            chosenBaseMatrix = filterMap[activeFilterValue] || "";
        }

        // Apply style stacking rules back to layout
        cropperCanvas.style.filter = `${chosenBaseMatrix} brightness(${brightness}%) contrast(${contrast}%)`.trim();
    }
}
