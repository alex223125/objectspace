import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

export default class extends Controller {
    // static targets = [ "input", "preview", "cropperContainer", "cropImage", "filterSelect", "brightnessSlider", "brightnessVal", "contrastSlider", "contrastVal" ]
    static targets = [ "input", "preview", "cropperContainer", "cropImage", "filterSelect", "brightnessSlider", "brightnessVal", "contrastSlider", "contrastVal", "zoomSlider", "zoomVal" ]

    connect() {
        this.cropper = null
        console.log("Algorithm cover quest engine initialized successfully with Cropper v2.")
    }

    // A. Triggered when a file is selected
    handleSelection(event) {
        const file = event.target.files[0]
        if (!file) return

        const reader = new FileReader()
        reader.onload = (e) => {
            this.cropImageTarget.src = e.target.result

            // Reveal the interactive cropping container workspace element frame
            this.cropperContainerTarget.classList.remove("hidden")

            // Reset slider defaults securely when a brand new file is loaded
            if (this.hasZoomSliderTarget) {
                this.zoomSliderTarget.value = "100";
                this.zoomValTarget.textContent = "100%";
            }

            // Initialize Cropper v2 instance
            if (this.cropper) {
                this.cropper.destroy()
            }

            // Cropper v2 automatically initializes and configures custom elements underneath
            this.cropper = new Cropper(this.cropImageTarget, {
                aspectRatio: 21 / 7,            // Your cinematic widescreen banner ratio
                viewMode: 1,                    // Restricts the crop box from bleeding past image boundaries
                initialAspectRatio: 21 / 7,
                autoCropArea: 1.0,              // CRUCIAL: Forces the active grid mesh box to span 100% of the canvas horizontal layer
                dragMode: 'move',               // Permits free fluid navigation dragging actions
                responsive: true,
                checkOrientation: false,
                modal: true,                    // Highlights the active crop mesh frame clearly against the dark panel
                ready() {
                    console.log("Cropper engine canvas boundary upscaled successfully.");
                }
            })
        }
        reader.readAsDataURL(file)
    }

    // B. Commit & Seal current parameters into standard form upload parameters
    // B. Commit & Seal current parameters into standard form upload parameters
    async applyModifications(event) {
        event.preventDefault()
        if (!this.cropper) return



        try {

            //////////////////////////////////////////////////////////////////////////////////////////////////////////
            // Add this rotation burn sequence inside your applyModifications() try block:
            const cropperImage = this.element.querySelector("cropper-image");
            if (cropperImage) {
                const finalRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
                const finalScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1;
                const finalScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1;

                if (finalRotate !== 0 || finalScaleX !== 1 || finalScaleY !== 1) {
                    // Translate center coordinates to pivot the image array correctly on final save
                    ctx.translate(canvas.width / 2, canvas.height / 2);
                    ctx.scale(finalScaleX, finalScaleY);
                    ctx.rotate((finalRotate * Math.PI) / 180);
                    ctx.translate(-canvas.width / 2, -canvas.height / 2);
                }
            }
            //////////////////////////////////////////////////////////////////////////////////////////////////////////


            //////////////////////////////////////////////////////////////////////////////////////////////////////////
            // 1.Fine-Tuned Brightness & Contrast Calibration Controls
            // Update inside your applyModifications() try block:
            const brightness = this.brightnessSliderTarget.value;
            const contrast = this.contrastSliderTarget.value;

            // Inject combined values right into the canvas drawing engine context before generating blobs
            tempCtx.filter = `${filterMap[filterValue] || "none"} brightness(${brightness}%) contrast(${contrast}%)`;
            //////////////////////////////////////////////////////////////////////////////////////////////////////////

            // const cropperSelection = this.element.querySelector("cropper-selection")


            // Locate this exact section inside your applyModifications() method and modify as follows:
            const cropperSelection = this.element.querySelector("cropper-selection")
            if (!cropperSelection) return

            // FIXED FOR V2 DYNAMIC RATIOS: Let Cropper calculate dimensions automatically based on selected aspect ratio box
            const canvas = await cropperSelection.$toCanvas({
                maxWidth: 2000,
                maxHeight: 2000
            })

            // Safely reference our filterSelect target element properties
            const filterValue = this.hasFilterSelectTarget ? this.filterSelectTarget.value : "none"


            // if (!cropperSelection) return

            // Asynchronously fetch the raw canvas element array parameters map from v2 components [POST]
            // const canvas = await cropperSelection.$toCanvas({
            //     width: 1200,
            //     height: 400
            // })

            if (!canvas) return



            // // Add this rotation burn sequence inside your applyModifications() try block:
            // const cropperImage = this.element.querySelector("cropper-image");
            // if (cropperImage) {
            //     const finalRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
            //     const finalScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1;
            //     const finalScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1;
            //
            //     if (finalRotate !== 0 || finalScaleX !== 1 || finalScaleY !== 1) {
            //         // Translate center coordinates to pivot image array correctly
            //         ctx.translate(canvas.width / 2, canvas.height / 2);
            //         ctx.scale(finalScaleX, finalScaleY);
            //         ctx.rotate((finalRotate * Math.PI) / 180);
            //         ctx.translate(-canvas.width / 2, -canvas.height / 2);
            //     }
            // }



            const ctx = canvas.getContext("2d")

            // === CRUCIAL V2 FIX: Permanent pixel modification filter burn engine ===
            // if (filterValue !== "none") {
            //     // Instantiating a secondary temporary canvas background layer to process filter parameters safely
            //     const tempCanvas = document.createElement("canvas");
            //     tempCanvas.width = canvas.width;
            //     tempCanvas.height = canvas.height;
            //     const tempCtx = tempCanvas.getContext("2d");
            //
            //     // Map the active dropdown value onto the temporary drawing context pipeline filters
            //     if (filterValue === "grayscale") tempCtx.filter = "grayscale(100%)";
            //     if (filterValue === "sepia") tempCtx.filter = "sepia(100%)";
            //     if (filterValue === "invert") tempCtx.filter = "invert(100%)";
            //     if (filterValue === "saturate-150") tempCtx.filter = "saturate(170%)";
            //
            //     // Redraw original canvas into the temporary filter context layer sheet
            //     tempCtx.drawImage(canvas, 0, 0);
            //
            //     // Clear out original context mapping and stamp back the filtered pixel arrays permanent
            //     ctx.clearRect(0, 0, canvas.width, canvas.height);
            //     ctx.drawImage(tempCanvas, 0, 0);
            // }
            // =======================================================================
            // pixel matrix into canvas file
            if (filterValue !== "none") {
                const tempCanvas = document.createElement("canvas");
                tempCanvas.width = canvas.width;
                tempCanvas.height = canvas.height;
                const tempCtx = tempCanvas.getContext("2d");

                // passing details CSS-matrix of filtration to context of  Canvas API [POST]
                const filterMap = {
                    "vintage": "sepia(40%) saturate(120%) contrast(90%) hue-rotate(-10deg)",
                    "parchment": "sepia(30%) contrast(95%) brightness(105%) saturate(80%)",
                    "faded-log": "brightness(130%) contrast(85%) saturate(70%)",
                    "dim-manuscript": "brightness(75%) contrast(110%) saturate(60%)",
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
                    // Basic standarts
                    "grayscale": "grayscale(100%)",
                    "sepia": "sepia(100%)",
                    "invert": "invert(100%)",
                    "saturate-150": "saturate(170%)",
                    // Optical
                    "blueprint-cyan": "contrast(140%) brightness(95%) sepia(100%) hue-rotate(160deg) saturate(250%) opacity(90%)",
                    "xray-spectre": "grayscale(100%) invert(100%) brightness(110%) contrast(150%)",
                    "high-shadows": "contrast(160%) brightness(85%) saturate(90%)",
                    "monochrome-glow": "grayscale(100%) brightness(120%) contrast(130%) sepia(100%) hue-rotate(75deg) saturate(300%)",
                    "high-dynamic": "contrast(135%) saturate(160%) brightness(110%)"
                };

                tempCtx.filter = filterMap[filterValue] || "none";
                tempCtx.drawImage(canvas, 0, 0);

                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.drawImage(tempCanvas, 0, 0);
            }
            // =======================================================================

            // Your existing watermark drawing sequence continues cleanly right underneath:
            ctx.font = "bold 14px monospace"
            ctx.fillStyle = "rgba(6, 182, 212, 0.4)"
            ctx.fillText("// OBJECTSPACE_SECURE_COGNITIVE_REVISION", 24, canvas.height - 24)

            // Convert canvas map to high-fidelity DataURL blob string data payload
            const dataUrl = canvas.toDataURL("image/jpeg", 0.92)

            // Inject the modified base64 data stream straight into a preview thumbnail card element
            this.previewTarget.innerHTML = `
                <div class="relative w-full h-full aspect-[21/7] md:aspect-square">
                  <img src="${dataUrl}" class="w-full h-full object-cover rounded-xl" />
                  <span class="absolute top-2 left-2 bg-emerald-500/90 text-white font-mono text-[8px] px-1.5 py-0.5 rounded border border-emerald-400 font-black tracking-widest uppercase animate-pulse">✓ Ready to Inscribe</span>
                </div>
            `

            // Generate a file transmission blob to override the native file selection parameters array input structure
            canvas.toBlob((blob) => {
                const croppedFile = new File([blob], "algorithm_cover_processed.jpg", { type: "image/jpeg" })

                // Programmatically patch the file array parameter list inside your actual file field tag
                const dataTransfer = new DataTransfer()
                dataTransfer.items.add(croppedFile)
                this.inputTarget.files = dataTransfer.files

                // Gracefully collapse the cropper tool frame workspace overlay array
                this.cropperContainerTarget.classList.add("hidden")
            }, "image/jpeg", 0.92)

        } catch (error) {
            console.error("Error executing dynamic canvas crop parameters pipeline:", error)
        }
    }

    applyFilter(event) {
        const filterValue = event.target.value;
        const cropperCanvas = this.element.querySelector("cropper-canvas");

        if (!cropperCanvas) {
            console.error("Cannot apply filter: <cropper-canvas> element layout empty.");
            return;
        }

        // Скідваем папярэднія стылі
        cropperCanvas.style.filter = "none";

        // CSS-matrix effects filters
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

            // Technical
            "night-vision": "matrix(0, 0, 0, 0, 0,  0, 1.3, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0, 1, 0) sepia(100%) hue-rotate(85deg) saturate(200%) contrast(140%)",
            "thermal-sensor": "invert(100%) hue-rotate(180deg) saturate(300%) contrast(150%)",
            "amber-cathode": "grayscale(100%) sepia(100%) hue-rotate(5deg) saturate(400%) contrast(120%) brightness(95%)",
            "cyan-laser": "grayscale(100%) sepia(100%) hue-rotate(145deg) saturate(350%) contrast(120%)",
            "glitch-ghost": "invert(80%) hue-rotate(90deg) contrast(150%) saturate(50%)",

            // Telemetry
            "overclocked": "saturate(300%) contrast(130%) brightness(105%)",
            "dark-matter": "hue-rotate(30deg) brightness(85%) contrast(90%) saturate(50%)",
            "solar-flare": "contrast(180%) invert(15%) hue-rotate(-30deg) saturate(200%)",
            "neon-cyber": "hue-rotate(290deg) saturate(180%) contrast(125%)",
            "toxic-waste": "hue-rotate(60deg) saturate(250%) contrast(160%) brightness(110%)",

            // Extra-Terrestrial
            "martian-soil": "sepia(100%) hue-rotate(-30deg) saturate(250%) contrast(110%)",
            "deep-space": "hue-rotate(200deg) brightness(80%) contrast(120%) saturate(60%)",
            "aurora": "hue-rotate(100deg) saturate(160%) brightness(95%) contrast(115%)",
            "supernova": "brightness(180%) contrast(150%) saturate(140%)",
            "pulsar": "contrast(150%) brightness(60%) saturate(110%) hue-rotate(45deg)",

            // Alchemy
            "golden-ratio": "sepia(100%) hue-rotate(15deg) saturate(250%) contrast(105%) brightness(105%)",
            "quicksilver": "grayscale(100%) brightness(115%) contrast(130%)",
            "copper-rust": "sepia(80%) hue-rotate(110deg) saturate(200%) contrast(110%)",
            "charcoal-ash": "grayscale(100%) brightness(50%) contrast(140%)",
            "amethyst": "sepia(100%) hue-rotate(240deg) saturate(250%) contrast(115%)",

            // Optical analysis
            "blueprint-cyan": "contrast(140%) brightness(95%) sepia(100%) hue-rotate(160deg) saturate(250%) opacity(90%)",
            "xray-spectre": "grayscale(100%) invert(100%) brightness(110%) contrast(150%)",
            "high-shadows": "contrast(160%) brightness(85%) saturate(90%)",
            "monochrome-glow": "grayscale(100%) brightness(120%) contrast(130%) sepia(100%) hue-rotate(75deg) saturate(300%)",
            "high-dynamic": "contrast(135%) saturate(160%) brightness(110%)"
        };

        cropperCanvas.style.filter = filterMap[filterValue] || "none";
        console.log(`System blueprint pipeline filter altered to array variable index: [${filterValue}]`);
    }

    // // Add this method inside your Stimulus controller class:
    // applyFilter(event) {
    //     const filterValue = event.target.value;
    //     const cropperCanvas = this.element.querySelector("cropper-canvas");
    //
    //     if (!cropperCanvas) {
    //         console.error("Cannot apply filter: <cropper-canvas> component not found inside DOM tree.");
    //         return;
    //     }
    //
    //     // Reset any existing style matrix filter parameters
    //     cropperCanvas.style.filter = "none";
    //
    //     // Map selection value to explicit native CSS filter values
    //     switch (filterValue) {
    //         case "grayscale":
    //             cropperCanvas.style.filter = "grayscale(100%)";
    //             break;
    //         case "sepia":
    //             cropperCanvas.style.filter = "sepia(100%)";
    //             break;
    //         case "invert":
    //             cropperCanvas.style.filter = "invert(100%)";
    //             break;
    //         case "saturate-150":
    //             cropperCanvas.style.filter = "saturate(1.7)";
    //             break;
    //         default:
    //             cropperCanvas.style.filter = "none";
    //     }
    //
    //     console.log(`Archival matrix filter successfully executed: ${filterValue}`);
    // }

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



    // Real-Time Dynamic Rotation & Axis Flipping Controls feature
    // Add these methods inside your Stimulus controller class:
    // Update these 4 methods inside your Stimulus controller:
    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js
    // Replace these 4 methods inside your Stimulus controller:
    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js
    // Replace these 4 orientation methods inside your Stimulus controller:
    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js
    // Replace these 4 orientation methods inside your Stimulus controller:
    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js
    // Replace these 4 orientation methods inside your Stimulus controller:
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






    //////////////////////////////////////////////////////////////////////////////////////////

    // Update these specific method blocks inside your Stimulus controller class:
    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js

    // handleSelection(event) {
    //     const file = event.target.files[0]
    //     if (!file) return
    //
    //     const reader = new FileReader()
    //     reader.onload = (e) => {
    //         this.cropImageTarget.src = e.target.result
    //         this.cropperContainerTarget.classList.remove("hidden")
    //
    //         // Reset zoom tracking memory values when a fresh file is chosen
    //         this.previousZoom = 1.0;
    //         if (this.hasZoomSliderTarget) {
    //             this.zoomSliderTarget.value = "100";
    //             this.zoomValTarget.textContent = "100%";
    //         }
    //
    //         if (this.cropper) {
    //             this.cropper.destroy()
    //         }
    //
    //         this.cropper = new Cropper(this.cropImageTarget, {
    //             aspectRatio: 21 / 7,
    //             viewMode: 1,
    //             initialAspectRatio: 21 / 7,
    //             autoCropArea: 1.0,
    //             dragMode: 'move',
    //             responsive: true,
    //             checkOrientation: false,
    //             modal: true
    //         })
    //     }
    //     reader.readAsDataURL(file)
    // }

    // FIXED WORKSPACE: Tracks strict linear step deltas to stop layout compression glitches
    // Add these 3 zoom manipulation methods inside your Stimulus controller class:
    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js
    // ABSOLUTE TRACKING SOLUTION: Bypasses relative compounding errors entirely
    scaleCanvasZoom() {
        const cropperImage = this.element.querySelector("cropper-image");
        if (!cropperImage) return;

        // Convert current slider step value directly to a percentage string
        const currentZoomPercent = parseInt(this.zoomSliderTarget.value);
        this.zoomValTarget.textContent = `${currentZoomPercent}%`;

        // Map percentage seamlessly to absolute float value bounds (e.g. 45% -> 0.45, 200% -> 2.0)
        const absoluteScale = currentZoomPercent / 100;

        // Force absolute scale variables directly onto the reactive Web Component attributes
        cropperImage.setAttribute("scale", absoluteScale);
        cropperImage.scale = absoluteScale;

        // Invoke the custom element's native refresh method to instantly push down changes to screen
        if (typeof cropperImage.$render === "function") {
            cropperImage.$render();
        }

        console.log(`Absolute canvas zoom safely mapped to: ${currentZoomPercent}%`);
    }

    zoomInStep(event) {
        event.preventDefault()

        // 1. Get current slider element boundaries
        const slider = this.zoomSliderTarget
        const currentVal = parseInt(slider.value, 10)
        const maxVal = parseInt(slider.max, 10) || 200
        const step = 5 // Adjust step increment to match your log interval jumps

        // 2. Calculate new value and enforce boundaries
        const newVal = Math.min(currentVal + step, maxVal)

        // 3. CRITICAL: Update the DOM slider component so it moves visually
        slider.value = newVal

        // 4. Update internal state (convert e.g., 144 to 1.44)
        this.currentScale = newVal / 100

        // 5. CRITICAL: Fire your rendering function to repaint the canvas surface
        this.drawCanvas()

        // Optional: If your logging is wrapped in a dedicated function, call it here:
        // console.log(`Absolute canvas zoom safely mapped to: ${newVal}%`)
    }

    zoomOutStep(event) {
        event.preventDefault();
        const currentVal = parseInt(this.zoomSliderTarget.value);
        // Step backward by 15 percent increments down to a minimum bounds safety lock of 20%
        const newVal = Math.max(20, currentVal - 15);

        this.zoomSliderTarget.value = newVal;
        this.scaleCanvasZoom();
    }


    drawCanvas() {
        // 1. Ensure the canvas element and the persistent image exist
        if (!this.hasCanvasTarget || !this.coverImage) {
            console.warn("Canvas target or coverImage instance is missing!")
            return
        }

        const canvas = this.canvasTarget
        const ctx = canvas.getContext("2d")

        // 2. Clear the entire workplace viewport area
        ctx.clearRect(0, 0, canvas.width, canvas.height)

        // 3. Save clean state context
        ctx.save()

        // 4. Move origin coordinates to the center of your workplace frame
        ctx.translate(canvas.width / 2, canvas.height / 2)

        // 5. Apply the scale from the zoomSlider (e.g. 1.75)
        ctx.scale(this.currentScale, this.currentScale)

        // 6. Draw the image offset by half its size so it centers on the origin
        ctx.drawImage(
            this.coverImage,
            -this.coverImage.width / 2,
            -this.coverImage.height / 2
        )

        // 7. Restore canvas state matrix
        ctx.restore()
    }




}
