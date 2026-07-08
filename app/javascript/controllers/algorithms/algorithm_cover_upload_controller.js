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
     * Fully optimized for Cropper.js v1 native live preview streaming pipelines with null-blob firewall guards
     */
    handleSelection(event) {
        // CRITICAL LOOP BREAKER: If the file change event was fired by our own background crop loop, EXIT EARLY!
        if (this.isProcessingCrop) {
            console.log("[Cropper Matrix Guard] Ignored echo change event. Auto-zoom aborted.");
            return;
        }

        // FIXED CRASH FIREWALL: Check if files array exists and contains at least one item
        if (!event.target || !event.target.files || event.target.files.length === 0) {
            console.log("[Cropper Guard] Prevented empty change trigger crash. Process bypassed safely.");
            return;
        }

        // Safely extract the first actual user-uploaded image file
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            // Unhide the interactive workspace editor workspace modal layer
            this.cropperContainerTarget.classList.remove("hidden");
            this.cropImageTarget.src = e.target.result;

            // Caching original base64 layout to prevent image loss between multi-move selections
            this.originalUploadedImageBase64 = e.target.result;

            if (this.hasZoomSliderTarget) {
                this.zoomSliderTarget.value = "100";
                this.zoomValTarget.textContent = "100%";
            }

            // Clean up old active library memory instances to prevent event collisions
            if (this.cropper) {
                this.cropper.destroy();
                this.cropper = null;
            }

            console.log("[Cropper v1] Initializing high-utility native live preview streaming engine...");

            // Instantiate native Cropper v1 on your standard ERB <img> form tag
            this.cropper = new Cropper(this.cropImageTarget, {
                // AUTOMATICALLY STREAMS CHOSEN BOUNDS DIRECTLY TO PREVIEW BANNER
                preview: '.algorithm-live-preview-banner',

                // 3:1 geometry scale constraint parameters matching aspect-[21/7]
                aspectRatio: 3,

                // Restricts selection box transformations within real asset dimensions
                viewMode: 1,

                autoCropArea: 0.9,
                responsive: true,
                background: false,
                movable: true,
                resizable: true,
                zoomable: true,

                // Built-in crop event callback fires natively on every single drag gesture
                crop: (cropEvent) => {
                    // Prevent processing loops if background transmissions are actively locking the fields
                    if (this.isProcessingCrop) return;

                    // =======================================================================
                    // AUTOMATED REAL-TIME BINARY SELECTION FILE PERSISTENCE
                    // Automatically updates your hidden input files payload list continuously
                    // behind the scenes without dropping image caches or closing panels.
                    // =======================================================================
                    const croppedCanvas = this.cropper.getCroppedCanvas();
                    if (!croppedCanvas) return;

                    croppedCanvas.toBlob((blob) => {
                        if (!blob) return;
                        const croppedFile = new File([blob], "algorithm_cover_processed.jpg", { type: "image/jpeg" });
                        const dataTransfer = new DataTransfer();
                        dataTransfer.items.add(croppedFile);

                        const fileInput = document.getElementById("algorithm_cover_file_input");
                        if (fileInput) {
                            // Turn loop lock ON to block handleSelection re-triggers
                            this.isProcessingCrop = true;

                            fileInput.files = dataTransfer.files;

                            // Programmatically dispatch a native change event so Rails UJS / Turbo knows the file input was updated
                            fileInput.dispatchEvent(new Event("change", { bubbles: true }));

                            // Turn loop lock OFF immediately after event propagation finishes
                            this.isProcessingCrop = false;
                        }
                    }, "image/jpeg", 0.90);
                }
            });
        };
        reader.readAsDataURL(file);
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



    /**
     * Live Preview Filter Matrix Mapping (Fixed Scope for Cropper v2 Shadow DOM)
     * Connected to: change->algorithm_cover_upload#applyFilter
     */
    applyFilter(event) {
        if (!this.cropper) return;
        const filterValue = event.target.value;
        this.filterType = filterValue;

        const cropperCanvas = this.cropper.getCropperCanvas();
        if (!cropperCanvas) return;

        cropperCanvas.style.filter = "none";

        if (filterValue === "comic-halftone") {
            const cropperSelection = cropperCanvas.querySelector("cropper-selection");
            if (cropperSelection) {
                cropperSelection.$toCanvas({ maxWidth: 1000, maxHeight: 1000 }).then((canvas) => {
                    if (!canvas) return;
                    const ctx = canvas.getContext("2d");
                    this.applyComicHalftone(canvas, ctx);
                    const processedDataUrl = canvas.toDataURL("image/png");

                    const innerImage = cropperCanvas.querySelector("cropper-image");
                    if (innerImage) {
                        cropperCanvas.style.filter = "none";
                        if (this.hasCropImageTarget) {
                            this.cropImageTarget.src = processedDataUrl;
                        }
                    }
                    this.renderLivePreview(); // Sync top banner after promise resolves
                });
            }
            return;
        }

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


        const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100;
        const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100;

        cropperCanvas.style.filter = `${filterMap[filterValue] || "none"} brightness(${brightness}%) contrast(${contrast}%)`;

        // =======================================================================
        // LIVE REACTIVE PREVIEW TRIGGER
        // =======================================================================
        this.renderLivePreview();
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


    /**
     * Realtime Brightness/Contrast Adjustment Interface Slider Triggers
     * Connected to: input->algorithm_cover_upload#tuneImageAdjustments
     */
    tuneImageAdjustments() {
        if (!this.cropper) return;

        // Extract the canvas container component safely out of the Cropper v2 instance wrapper
        const cropperCanvas = this.cropper.getCropperCanvas();
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

        let chosenBaseMatrix = "";
        if (activeComicStyle !== "none") {
            chosenBaseMatrix = comicStylesMap[activeComicStyle] || "";
        } else {
            chosenBaseMatrix = filterMap[activeFilterValue] || "";
        }

        // Apply style stacking rules back to layout viewport
        cropperCanvas.style.filter = `${chosenBaseMatrix} brightness(${brightness}%) contrast(${contrast}%)`.trim();

        // =======================================================================
        // LIVE REACTIVE PREVIEW TRIGGER
        // Immediately fires background matrix calculations to sync the top cover banner
        // =======================================================================
        this.renderLivePreview();
    }

    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js
    rotateLeft(event) {
        event.preventDefault();
        if (!this.cropper) return;

        const cropperCanvas = this.cropper.getCropperCanvas();
        if (!cropperCanvas) return;

        const cropperImage = cropperCanvas.querySelector("cropper-image");
        if (cropperImage) {
            const currentRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
            const newRotate = currentRotate - 90;

            cropperImage.setAttribute("rotate", newRotate);
            cropperImage.rotate = newRotate;
            console.log(`Canvas rotated left to: ${newRotate}`);

            // TRIGGER LIVE SYNC PIPELINE
            this.renderLivePreview();
        }
    }

    rotateRight(event) {
        event.preventDefault();
        if (!this.cropper) return;

        const cropperCanvas = this.cropper.getCropperCanvas();
        if (!cropperCanvas) return;

        const cropperImage = cropperCanvas.querySelector("cropper-image");
        if (cropperImage) {
            const currentRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
            const newRotate = currentRotate + 90;

            cropperImage.setAttribute("rotate", newRotate);
            cropperImage.rotate = newRotate;
            console.log(`Canvas rotated right to: ${newRotate}`);

            // TRIGGER LIVE SYNC PIPELINE
            this.renderLivePreview();
        }
    }

    flipHorizontal(event) {
        event.preventDefault();
        if (!this.cropper) return;

        const cropperCanvas = this.cropper.getCropperCanvas();
        if (!cropperCanvas) return;

        const cropperImage = cropperCanvas.querySelector("cropper-image");
        if (cropperImage) {
            const currentScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1;
            const newScaleX = currentScaleX === 1 ? -1 : 1;

            cropperImage.setAttribute("scale-x", newScaleX);
            cropperImage.scaleX = newScaleX;
            console.log(`Canvas flipped horizontally: ${newScaleX}`);

            // TRIGGER LIVE SYNC PIPELINE
            this.renderLivePreview();
        }
    }

    flipVertical(event) {
        event.preventDefault();
        if (!this.cropper) return;

        const cropperCanvas = this.cropper.getCropperCanvas();
        if (!cropperCanvas) return;

        const cropperImage = cropperCanvas.querySelector("cropper-image");
        if (cropperImage) {
            const currentScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1;
            const newScaleY = currentScaleY === 1 ? -1 : 1;

            cropperImage.setAttribute("scale-y", newScaleY);
            cropperImage.scaleY = newScaleY;
            console.log(`Canvas flipped vertically: ${newScaleY}`);

            // TRIGGER LIVE SYNC PIPELINE
            this.renderLivePreview();
        }
    }

    // Add this method into your Stimulus controller class architecture:
    // app/javascript/controllers/algorithms/algorithm_cover_upload_controller.js

    changeAspectRatio(event) {
        event.preventDefault();
        if (!this.cropper) return;

        const targetRatio = parseFloat(event.currentTarget.dataset.ratio);
        const cropperCanvas = this.cropper.getCropperCanvas();
        if (!cropperCanvas) return;

        const cropperSelection = cropperCanvas.querySelector("cropper-selection");
        if (cropperSelection) {
            cropperSelection.aspectRatio = targetRatio;
            cropperSelection.resizable = true;
            cropperSelection.movable = true;

            // Restyle dashboard tab layout items active state
            const buttons = event.currentTarget.parentElement.querySelectorAll("button");
            buttons.forEach(btn => {
                btn.className = "px-3 py-1.5 text-[11px] font-mono font-black rounded-lg transition-all cursor-pointer text-slate-600 hover:bg-slate-50";
            });
            event.currentTarget.className = "px-3 py-1.5 bg-white border border-slate-200 text-[11px] font-mono font-black text-cyan-600 rounded-lg shadow-sm transition-all cursor-pointer";

            console.log(`Proportions updated to: ${targetRatio}`);

            // TRIGGER LIVE SYNC PIPELINE
            this.renderLivePreview();
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

        // CRITICAL FIX: Pierce the Shadow DOM cleanly using Cropper v2 instance reference
        const cropperCanvas = this.cropper.getCropperCanvas();
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

        // =======================================================================
        // LIVE REACTIVE PREVIEW TRIGGER
        // Instantly bakes the comic style filter change onto the large horizontal
        // upper banner preview container asynchronously.
        // =======================================================================
        this.renderLivePreview();
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

    async applyModifications(event) {
        event.preventDefault()
        if (!this.cropper) return

        try {
            console.log("[Cropper v2] Executing static, non-mutating canvas slice extraction...");

            const cropperCanvas = this.cropper.getCropperCanvas()
            if (!cropperCanvas) return

            const cropperSelection = cropperCanvas.querySelector("cropper-selection")
            const cropperImage = cropperCanvas.querySelector("cropper-image")
            if (!cropperSelection || !cropperImage) return

            // 1. Fetch exact pixel bounds directly from properties to avoid internal auto-zoom triggers
            const x = cropperSelection.x || 0;
            const y = cropperSelection.y || 0;
            const width = cropperSelection.width || 300;
            const height = cropperSelection.height || 100;

            // 2. Create detached canvas wrapper context
            const canvas = document.createElement("canvas");
            canvas.width = width;
            canvas.height = height;
            const ctx = canvas.getContext("2d");

            const rawImageElement = new Image();
            rawImageElement.src = this.cropImageTarget.src;

            await new Promise((resolve) => {
                if (rawImageElement.complete) resolve();
                else rawImageElement.onload = () => resolve();
            });

            ctx.drawImage(rawImageElement, x, y, width, height, 0, 0, width, height);

            // 3. Read slider node configuration configurations adjustments live
            const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100
            const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100
            const activeFilterValue = this.hasFilterSelectTarget ? this.filterSelectTarget.value : "none"
            const activeComicStyle = this.hasComicStyleSelectTarget ? this.comicStyleSelectTarget.value : "none"

            // 4. Orientation matrix updates calculations
            const finalRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0
            const finalScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1
            const finalScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1

            if (finalRotate !== 0 || finalScaleX !== 1 || finalScaleY !== 1) {
                const transCanvas = document.createElement("canvas")
                transCanvas.width = canvas.width
                transCanvas.height = canvas.height
                const transCtx = transCanvas.getContext("2d")

                transCtx.translate(canvas.width / 2, canvas.height / 2)
                transCtx.scale(finalScaleX, finalScaleY)
                transCtx.rotate((finalRotate * Math.PI) / 180)
                transCtx.translate(-canvas.width / 2, -canvas.height / 2)

                transCtx.drawImage(canvas, 0, 0)

                ctx.clearRect(0, 0, canvas.width, canvas.height)
                ctx.drawImage(transCanvas, 0, 0)
            }

            // 5. Matrix Styles dictionaries mapping configurations
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

            let chosenBaseMatrix = ""
            if (activeComicStyle !== "none") {
                chosenBaseMatrix = comicStylesMap[activeComicStyle] || ""
            } else {
                chosenBaseMatrix = filterMap[activeFilterValue] || ""
            }

            const hasCustomStyles = chosenBaseMatrix !== "" || parseInt(brightness) !== 100 || parseInt(contrast) !== 100

            if (hasCustomStyles) {
                const tempCanvas = document.createElement("canvas")
                tempCanvas.width = canvas.width
                tempCanvas.height = canvas.height
                const tempCtx = tempCanvas.getContext("2d")

                tempCtx.filter = `${chosenBaseMatrix} brightness(${brightness}%) contrast(${contrast}%)`.trim()
                tempCtx.drawImage(canvas, 0, 0)

                if (activeFilterValue === "comic-halftone" && typeof this.applyComicHalftone === "function") {
                    this.applyComicHalftone(tempCanvas, tempCtx)
                }

                ctx.clearRect(0, 0, canvas.width, canvas.height)
                ctx.drawImage(tempCanvas, 0, 0)
            }

            // 6. Technical Watermark parameter allocation
            ctx.font = "bold 14px monospace"
            ctx.fillStyle = "rgba(6, 182, 212, 0.4)"
            ctx.fillText("// OBJECTSPACE_SECURE_COGNITIVE_REVISION", 24, canvas.height - 24)

            // 7. Extract the high-fidelity output string data stream
            const dataUrl = canvas.toDataURL("image/jpeg", 0.92)

            // =======================================================================
            // PASTE THE COPIED BLOCK HERE: REFRESHES REPLICA horizontal LARGE BANNER VIEW
            // =======================================================================
            const previewContainer = this.hasPreviewTarget ? this.previewTarget : document.getElementById("algorithm_cover_preview_box");
            if (previewContainer) {
                // SINGLE QUOTES FIX: Keeps Esbuild/Vite build loaders stable without quote conflicts
                previewContainer.innerHTML = `
                    <div class='w-full h-full relative group overflow-hidden rounded-2xl'>
                      <img src='${dataUrl}' class='w-full h-full object-cover transition-transform duration-700 group-hover:scale-[1.02]' alt='Live Cropped Preview' />
                      <div class='absolute inset-0 bg-gradient-to-b from-transparent via-slate-950/10 to-slate-950/50'></div>
                      <span class='absolute bottom-4 left-4 bg-slate-900/90 text-white font-mono text-[10px] px-2.5 py-1 border border-slate-800 rounded font-black tracking-widest uppercase z-10'>// PREVIEW_LOCKED_READY</span>
                    </div>`;
                console.log("[Cropper Viewport] Large horizontal banner updated live on UI grid framework.");
            }

            // 9. Compress canvas back into a clean transmission binary file blob packet
            canvas.toBlob((blob) => {
                if (!blob) return
                const croppedFile = new File([blob], "algorithm_cover_processed.jpg", { type: "image/jpeg" })

                const dataTransfer = new DataTransfer()
                dataTransfer.items.add(croppedFile)

                const fileInput = document.getElementById("algorithm_cover_file_input")
                if (fileInput) {
                    // SECURE LOCK ON: Halts event loops from triggering an auto-zoom restart
                    this.isProcessingCrop = true;

                    fileInput.files = dataTransfer.files
                    fileInput.dispatchEvent(new Event("change", { bubbles: true }))

                    console.log("Transmission array patched: Selection dimensions preserved perfectly.");

                    // Safely release the lock after propagation finishes cleanly
                    setTimeout(() => {
                        this.isProcessingCrop = false;
                    }, 100);
                } else {
                    console.error("[Cropper Error] Target file input element not detected.");
                }

                // Workspace kept open for continuous adjustments (As requested, automatic close lines removed)
                console.log("[Cropper Viewport] Workspace window kept open for continuous adjustments.");

            }, "image/jpeg", 0.92)

        } catch (error) {
            console.error("Error executing dynamic canvas crop parameters pipeline:", error)
        }
    }


    /**
     * PASSIVE LIVE-SYNC CORE ENGINE
     * Extracts coordinates and applies styles silently onto an off-screen canvas,
     * immediately updating the top horizontal cover banner target wrapper layout.
     */
    async renderLivePreview() {
        if (!this.cropper) return;

        try {
            const cropperCanvas = this.cropper.getCropperCanvas();
            if (!cropperCanvas) return;

            const cropperSelection = cropperCanvas.querySelector("cropper-selection");
            const cropperImage = cropperCanvas.querySelector("cropper-image");
            if (!cropperSelection || !cropperImage) return;

            // 1. Gather exact, unmutated coordinates from active properties
            const x = cropperSelection.x || 0;
            const y = cropperSelection.y || 0;
            const width = cropperSelection.width || 300;
            const height = cropperSelection.height || 100;

            // Zero-dimension safety bypass guard clause
            if (width <= 0 || height <= 0) return;

            // 2. Build isolated background execution canvas space
            const canvas = document.createElement("canvas");
            canvas.width = width;
            canvas.height = height;
            const ctx = canvas.getContext("2d");

            const rawImageElement = new Image();
            rawImageElement.src = this.cropImageTarget.src;

            await new Promise((resolve) => {
                if (rawImageElement.complete) resolve();
                else rawImageElement.onload = () => resolve();
            });

            // Slice selected window coordinate map silently in background threads
            ctx.drawImage(rawImageElement, x, y, width, height, 0, 0, width, height);

            // 3. Read live interactive slider node adjustments values natively
            const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100;
            const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100;
            const activeFilterValue = this.hasFilterSelectTarget ? this.filterSelectTarget.value : "none";
            const activeComicStyle = this.hasComicStyleSelectTarget ? this.comicStyleSelectTarget.value : "none";

            // 4. Orientation geometric parameter matrix updates mapping
            const finalRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
            const finalScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1;
            const finalScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1

            if (finalRotate !== 0 || finalScaleX !== 1 || finalScaleY !== 1) {
                const transCanvas = document.createElement("canvas");
                transCanvas.width = canvas.width;
                transCanvas.height = canvas.height;
                const transCtx = transCanvas.getContext("2d");

                transCtx.translate(canvas.width / 2, canvas.height / 2);
                transCtx.scale(finalScaleX, finalScaleY);
                transCtx.rotate((finalRotate * Math.PI) / 180);
                transCtx.translate(-canvas.width / 2, -canvas.height / 2);

                transCtx.drawImage(canvas, 0, 0);

                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.drawImage(transCanvas, 0, 0);
            }

            // 5. Apply filters dictionaries matrix mapping profiles synchronization
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
                "pulsar": "contrast(150%) brightness(60%) saturate(110%) hue-rotate(450deg)",
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
            };

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

            let chosenBaseMatrix = activeComicStyle !== "none" ? comicStylesMap[activeComicStyle] : filterMap[activeFilterValue];
            chosenBaseMatrix = chosenBaseMatrix || "";

            const hasCustomStyles = chosenBaseMatrix !== "" || parseInt(brightness) !== 100 || parseInt(contrast) !== 100;

            if (hasCustomStyles) {
                const tempCanvas = document.createElement("canvas");
                tempCanvas.width = canvas.width;
                tempCanvas.height = canvas.height;
                const tempCtx = tempCanvas.getContext("2d");

                tempCtx.filter = `${chosenBaseMatrix} brightness(${brightness}%) contrast(${contrast}%)`.trim();
                tempCtx.drawImage(canvas, 0, 0);

                if (activeFilterValue === "comic-halftone" && typeof this.applyComicHalftone === "function") {
                    this.applyComicHalftone(tempCanvas, tempCtx);
                }

                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.drawImage(tempCanvas, 0, 0);
            }

            // 6. Append secure layout watermark overlay properties matrix elements
            ctx.font = "bold 14px monospace";
            ctx.fillStyle = "rgba(6, 182, 212, 0.4)";
            ctx.fillText("// OBJECTSPACE_SECURE_COGNITIVE_REVISION", 24, canvas.height - 24);

            // 7. Output complete base64 data stream straight onto large cover preview block element
            const dataUrl = canvas.toDataURL("image/jpeg", 0.92);

            const previewContainer = this.hasPreviewTarget ? this.previewTarget : document.getElementById("algorithm_cover_preview_box");
            if (previewContainer) {
                // FIXED SINGLE QUOTES: Satisfies compiler asset builders perfectly without quote conflicts
                previewContainer.innerHTML = `
                    <div class='w-full h-full relative group overflow-hidden rounded-2xl animate-fade-in'>
                      <img src='${dataUrl}' class='w-full h-full object-cover transition-transform duration-700' alt='Live Asynchronous Preview Node' />
                      <div class='absolute inset-0 bg-gradient-to-b from-transparent via-slate-950/10 to-slate-950/50'></div>
                      <span class='absolute bottom-4 left-4 bg-cyan-600/90 text-white font-mono text-[10px] px-2.5 py-1 border border-cyan-400 rounded font-black tracking-widest uppercase z-10 animate-pulse'>// ASYNC_LIVE_STREAM_ACTIVE</span>
                    </div>`;
            }

            // 8. Patch binary transmission bundle file directly to hidden input silently in background
            canvas.toBlob((blob) => {
                if (!blob) return;
                const croppedFile = new File([blob], "algorithm_cover_processed.jpg", { type: "image/jpeg" });
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(croppedFile);

                const fileInput = document.getElementById("algorithm_cover_file_input");
                if (fileInput) {
                    // SECURE STATE LOCK ON: Stops the event loop from forcing an auto-zoom reset loop
                    this.isProcessingCrop = true;

                    fileInput.files = dataTransfer.files;
                    fileInput.dispatchEvent(new Event("change", { bubbles: true }));

                    console.log("[Live Engine] Background binary transmission array patched successfully.");

                    // Safely release the lock after propagation finishes cleanly
                    setTimeout(() => {
                        this.isProcessingCrop = false;
                    }, 50);
                }
            }, "image/jpeg", 0.92);

        } catch (error) {
            console.error("[Live Preview Exception] Operational matrix capture failure:", error);
        }
    }


    tuneImageAdjustments() {
        if (!this.cropper) return;
        const cropperCanvas = this.cropper.getCropperCanvas();
        if (!cropperCanvas) return;

        const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100;
        const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100;

        if (this.hasBrightnessValTarget) this.brightnessValTarget.textContent = `${brightness}%`;
        if (this.hasContrastValTarget) this.contrastValTarget.textContent = `${contrast}%`;

        // (Keep your existing filter map string configurations logic here...)
        cropperCanvas.style.filter = `${chosenBaseMatrix} brightness(${brightness}%) contrast(${contrast}%)`.trim();

        // =======================================================================
        // RE-BAKE CACHE MATRIX INSTANTLY ON SLIDER INPUT
        // =======================================================================
        this.renderLivePreview();
    }



    /**
     * ASYNCHRONOUS LIVE PREVIEW STREAM ENGINE
     * Captures 1:1 pixel coordinates dynamically out of event.detail telemetry metrics.
     */
    /**
     * ASYNCHRONOUS LIVE PREVIEW STREAM ENGINE
     * Translates viewport bounds to 1:1 image resolution metrics natively.
     */
    async renderLivePreviewStream(event) {

        // Update the top of your renderLivePreviewStream(event) to handle the null event
        // stream flawlessly by fetching coordinates directly from the instance state map cache:
        let x, y, width, height;

        if (event && event.detail) {
            x = event.detail.x;
            y = event.detail.y;
            width = event.detail.width;
            height = event.detail.height;
        } else {
            // BULLETPROOF FALLBACK: Query the live coordinate context properties from the active component
            const selection = cropperCanvas.querySelector("cropper-selection");
            if (!selection) return;

            // Read reactive components bounds natively instead of using stale state targets
            x = parseFloat(selection.getAttribute("x")) || selection.x || 0;
            y = parseFloat(selection.getAttribute("y")) || selection.y || 0;
            width = parseFloat(selection.getAttribute("width")) || selection.width || 300;
            height = parseFloat(selection.getAttribute("height")) || selection.height || 100;
        }



        // Stop execution if form committal operations are locked or cropper is missing
        if (this.isProcessingCrop || !this.cropper) return;

        try {
            const cropperCanvas = this.cropper.getCropperCanvas();
            if (!cropperCanvas) return;

            const cropperSelection = cropperCanvas.querySelector("cropper-selection");
            const cropperImage = cropperCanvas.querySelector("cropper-image");
            if (!cropperSelection || !cropperImage) return;

            // =======================================================================
            // MANDATORY SPATIAL RATIO CALIBRATION
            // Computes scale variables between display space and raw image files
            // =======================================================================
            const viewX = cropperSelection.x || 0;
            const viewY = cropperSelection.y || 0;
            const viewW = cropperSelection.width || 300;
            const viewH = cropperSelection.height || 100;

            const imgWidth = cropperImage.width || 1;
            const imgHeight = cropperImage.height || 1;
            const natWidth = cropperImage.naturalWidth || this.cropImageTarget.naturalWidth;
            const natHeight = cropperImage.naturalHeight || this.cropImageTarget.naturalHeight;

            // Calculate exact compression offsets
            const scaleX = natWidth / imgWidth;
            const scaleY = natHeight / imgHeight;

            const x = viewX * scaleX;
            const y = viewY * scaleY;
            const width = viewW * scaleX;
            const height = viewH * scaleY;

            // Stop logic thread if selection parameters evaluate to zero
            if (width <= 0 || height <= 0 || isNaN(width) || isNaN(height)) return;

            // =======================================================================

            // Build isolated canvas space matching binary asset dimensions
            const canvas = document.createElement("canvas");
            canvas.width = width;
            canvas.height = height;
            const ctx = canvas.getContext("2d");

            const rawImageElement = new Image();
            rawImageElement.src = this.cropImageTarget.src;

            if (!rawImageElement.complete) {
                await new Promise((resolve) => { rawImageElement.onload = () => resolve(); });
            }

            // Slice raw coordinate mapping layout smoothly
            ctx.drawImage(rawImageElement, x, y, width, height, 0, 0, width, height);

            // Read interactive controls settings values natively
            const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100;
            const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100;
            const activeFilterValue = this.hasFilterSelectTarget ? this.filterSelectTarget.value : "none";
            const activeComicStyle = this.hasComicStyleSelectTarget ? this.comicStyleSelectTarget.value : "none";

            // Orientation parameter adjustments mapping matrix
            const finalRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
            const finalScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1;
            const finalScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1;

            if (finalRotate !== 0 || finalScaleX !== 1 || finalScaleY !== 1) {
                const transCanvas = document.createElement("canvas");
                transCanvas.width = canvas.width;
                transCanvas.height = canvas.height;
                const transCtx = transCanvas.getContext("2d");

                transCtx.translate(canvas.width / 2, canvas.height / 2);
                transCtx.scale(finalScaleX, finalScaleY);
                transCtx.rotate((finalRotate * Math.PI) / 180);
                transCtx.translate(-canvas.width / 2, -canvas.height / 2);

                transCtx.drawImage(canvas, 0, 0);

                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.drawImage(transCanvas, 0, 0);
            }

            // Complete matrix dictionaries data filtering configurations
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
            };

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

            let chosenBaseMatrix = activeComicStyle !== "none" ? comicStylesMap[activeComicStyle] : filterMap[activeFilterValue];
            chosenBaseMatrix = chosenBaseMatrix || "";

            const hasCustomStyles = chosenBaseMatrix !== "" || parseInt(brightness) !== 100 || parseInt(contrast) !== 100;

            if (hasCustomStyles) {
                const tempCanvas = document.createElement("canvas");
                tempCanvas.width = canvas.width;
                tempCanvas.height = canvas.height;
                const tempCtx = tempCanvas.getContext("2d");

                tempCtx.filter = `${chosenBaseMatrix} brightness(${brightness}%) contrast(${contrast}%)`.trim();
                tempCtx.drawImage(canvas, 0, 0);

                if (activeFilterValue === "comic-halftone" && typeof this.applyComicHalftone === "function") {
                    this.applyComicHalftone(tempCanvas, tempCtx);
                }

                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.drawImage(tempCanvas, 0, 0);
            }

            // Append secure layout watermark overlay properties matrix elements
            ctx.font = "bold 14px monospace";
            ctx.fillStyle = "rgba(6, 182, 212, 0.4)";
            ctx.fillText("// OBJECTSPACE_SECURE_COGNITIVE_REVISION", 24, canvas.height - 24);

            // Output complete base64 data stream straight onto large cover preview block element
            const dataUrl = canvas.toDataURL("image/jpeg", 0.90);

            const previewContainer = this.hasPreviewTarget ? this.previewTarget : document.getElementById("algorithm_cover_preview_box");
            if (previewContainer) {
                // FIXED SINGLE QUOTES: Satisfies compiler asset builders perfectly without quote conflicts
                previewContainer.innerHTML = `
                    <div class='w-full h-full relative group overflow-hidden rounded-2xl'>
                      <img src='${dataUrl}' class='w-full h-full object-cover' alt='Live Asynchronous Preview Node' />
                      <div class='absolute inset-0 bg-gradient-to-b from-transparent via-slate-950/10 to-slate-950/50'></div>
                      <span class='absolute bottom-4 left-4 bg-cyan-600/90 text-white font-mono text-[9px] px-2.5 py-1 border border-cyan-400 rounded font-black tracking-widest uppercase z-10 animate-pulse'>// ASYNC_LIVE_STREAM_ACTIVE</span>
                    </div>`;
            }

            // Patch binary transmission bundle file directly to hidden input silently in background
            canvas.toBlob((blob) => {
                if (!blob) return;
                const croppedFile = new File([blob], "algorithm_cover_processed.jpg", { type: "image/jpeg" });
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(croppedFile);

                const fileInput = document.getElementById("algorithm_cover_file_input");
                if (fileInput) {
                    // SECURE STATE LOCK ON: Stops the event loop from forcing an auto-zoom reset loop
                    this.isProcessingCrop = true;

                    fileInput.files = dataTransfer.files;
                    fileInput.dispatchEvent(new Event("change", { bubbles: true }));

                    console.log("[Live Engine] Background binary transmission array patched successfully.");

                    // Safely release the lock after propagation finishes cleanly
                    setTimeout(() => {
                        this.isProcessingCrop = false;
                    }, 50);
                }
            }, "image/jpeg", 0.90);

        } catch (error) {
            console.error("[Live Preview Exception] Operational matrix capture failure:", error);
        }
    }



    /**
     * Captures real-time slice modifications asynchronously from Cropper v1's native bubble loop.
     * Keeps the Rails ActiveStorage payload synchronized while you drag/resize without causing loops.
     * Connected to: data-action="crop->algorithm_cover_upload#handleLiveSelectionChange"
     */
    async handleLiveSelectionChange(event) {
        // Prevent event loop feedback echo locks when background transactions are running
        if (this.isProcessingCrop || !this.cropper) return;

        try {
            // =======================================================================
            // CRITICAL V1 CONVERSION FIX: Drop all getCropperCanvas() and Shadow DOM queries.
            // Cropper v1 already automatically updates the .algorithm-live-preview-banner
            // visual container using its native preview engine config.
            // =======================================================================

            const croppedCanvas = this.cropper.getCroppedCanvas();
            if (!croppedCanvas) return;

            // Silently persist the real-time cropped binary image straight into your hidden form input field
            croppedCanvas.toBlob((blob) => {
                if (!blob) return;

                const croppedFile = new File([blob], "algorithm_cover_processed.jpg", { type: "image/jpeg" });
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(croppedFile);

                const fileInput = document.getElementById("algorithm_cover_file_input");
                if (fileInput) {
                    // Turn loop safety lock ON to block handleSelection re-triggers
                    this.isProcessingCrop = true;

                    fileInput.files = dataTransfer.files;

                    // Programmatically dispatch a native change event so Rails knows the file field was updated
                    fileInput.dispatchEvent(new Event("change", { bubbles: true }));

                    // Release the lock immediately after propagation concludes
                    this.isProcessingCrop = false;
                }
            }, "image/jpeg", 0.90);

        } catch (error) {
            console.error("[Live Preview Exception] Operational matrix capture failure:", error);
        }
    }





    /**
     * DIRECT MEMORY STREAM SYNC ENGINE
     * Pierces the Shadow DOM directly to copy pixel data onto your top banner.
     */
    async executeDirectLiveSync() {
        // Halt background processing if a form commit is running or cropper is missing
        if (this.isProcessingCrop || !this.cropper) return;

        try {
            const cropperCanvas = this.cropper.getCropperCanvas();
            if (!cropperCanvas) return;

            const cropperSelection = cropperCanvas.querySelector("cropper-selection");
            const cropperImage = cropperCanvas.querySelector("cropper-image");
            if (!cropperSelection || !cropperImage) return;

            // 1. Fetch exact pixel bounds directly from properties to avoid internal auto-zoom triggers
            const viewX = cropperSelection.x || 0;
            const viewY = cropperSelection.y || 0;
            const viewW = cropperSelection.width || 300;
            const viewH = cropperSelection.height || 100;

            const imgWidth = cropperImage.width || 1;
            const imgHeight = cropperImage.height || 1;
            const natWidth = cropperImage.naturalWidth || this.cropImageTarget.naturalWidth;
            const natHeight = cropperImage.naturalHeight || this.cropImageTarget.naturalHeight;

            // Calculate precise scaling multipliers between screen pixels and the source resolution
            const scaleX = natWidth / imgWidth;
            const scaleY = natHeight / imgHeight;

            const x = viewX * scaleX;
            const y = viewY * scaleY;
            const width = viewW * scaleX;
            const height = viewH * scaleY;

            if (width <= 0 || height <= 0 || isNaN(width) || isNaN(height)) return;

            // 2. Create isolated background execution canvas space matching binary metrics
            const canvas = document.createElement("canvas");
            canvas.width = width;
            canvas.height = height;
            const ctx = canvas.getContext("2d");

            const rawImageElement = new Image();
            rawImageElement.src = this.cropImageTarget.src;

            if (!rawImageElement.complete) {
                await new Promise((resolve) => { rawImageElement.onload = () => resolve(); });
            }

            // Slice raw coordinate mapping layout smoothly
            ctx.drawImage(rawImageElement, x, y, width, height, 0, 0, width, height);

            // 3. Read slider node configuration adjustments live
            const brightness = this.hasBrightnessSliderTarget ? this.brightnessSliderTarget.value : 100;
            const contrast = this.hasContrastSliderTarget ? this.contrastSliderTarget.value : 100;
            const activeFilterValue = this.hasFilterSelectTarget ? this.filterSelectTarget.value : "none";
            const activeComicStyle = this.hasComicStyleSelectTarget ? this.comicStyleSelectTarget.value : "none";

            // 4. Orientation matrix updates calculations
            const finalRotate = parseFloat(cropperImage.getAttribute("rotate")) || 0;
            const finalScaleX = parseFloat(cropperImage.getAttribute("scale-x")) || 1;
            const finalScaleY = parseFloat(cropperImage.getAttribute("scale-y")) || 1;

            if (finalRotate !== 0 || finalScaleX !== 1 || finalScaleY !== 1) {
                const transCanvas = document.createElement("canvas");
                transCanvas.width = canvas.width;
                transCanvas.height = canvas.height;
                const transCtx = transCanvas.getContext("2d");

                transCtx.translate(canvas.width / 2, canvas.height / 2);
                transCtx.scale(finalScaleX, finalScaleY);
                transCtx.rotate((finalRotate * Math.PI) / 180);
                transCtx.translate(-canvas.width / 2, -canvas.height / 2);

                transCtx.drawImage(canvas, 0, 0);

                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.drawImage(transCanvas, 0, 0);
            }

            // 5. Complete matrix dictionaries data filtering configurations
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
            };

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

            let chosenBaseMatrix = activeComicStyle !== "none" ? comicStylesMap[activeComicStyle] : filterMap[activeFilterValue];
            chosenBaseMatrix = chosenBaseMatrix || "";

            const hasCustomStyles = chosenBaseMatrix !== "" || parseInt(brightness) !== 100 || parseInt(contrast) !== 100;

            if (hasCustomStyles) {
                const tempCanvas = document.createElement("canvas");
                tempCanvas.width = canvas.width;
                tempCanvas.height = canvas.height;
                const tempCtx = tempCanvas.getContext("2d");

                tempCtx.filter = `${chosenBaseMatrix} brightness(${brightness}%) contrast(${contrast}%)`.trim();
                tempCtx.drawImage(canvas, 0, 0);

                if (activeFilterValue === "comic-halftone" && typeof this.applyComicHalftone === "function") {
                    this.applyComicHalftone(tempCanvas, tempCtx);
                }

                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.drawImage(tempCanvas, 0, 0);
            }

            // Append secure layout watermark overlay properties matrix elements
            ctx.font = "bold 14px monospace";
            ctx.fillStyle = "rgba(6, 182, 212, 0.4)";
            ctx.fillText("// OBJECTSPACE_SECURE_COGNITIVE_REVISION", 24, canvas.height - 24);

            // 6. Output complete base64 data stream straight onto large cover preview block element
            const dataUrl = canvas.toDataURL("image/jpeg", 0.90);

            const previewContainer = this.hasPreviewTarget ? this.previewTarget : document.getElementById("algorithm_cover_preview_box");
            if (previewContainer) {
                // FIXED SINGLE QUOTES: Satisfies compiler asset builders perfectly without quote conflicts
                previewContainer.innerHTML = `
                    <div class='w-full h-full relative group overflow-hidden rounded-2xl'>
                      <img src='${dataUrl}' class='w-full h-full object-cover' alt='Live Asynchronous Preview Node' />
                      <div class='absolute inset-0 bg-gradient-to-b from-transparent via-slate-950/10 to-slate-950/50'></div>
                      <span class='absolute bottom-4 left-4 bg-cyan-600/90 text-white font-mono text-[9px] px-2.5 py-1 border border-cyan-400 rounded font-black tracking-widest uppercase z-10 animate-pulse'>// ASYNC_LIVE_STREAM_ACTIVE</span>
                    </div>`;
            }

            // 7. Patch binary transmission bundle file directly to hidden input silently in background
            canvas.toBlob((blob) => {
                if (!blob) return;
                const croppedFile = new File([blob], "algorithm_cover_processed.jpg", { type: "image/jpeg" });
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(croppedFile);

                const fileInput = document.getElementById("algorithm_cover_file_input");
                if (fileInput) {
                    // SECURE STATE LOCK ON: Stops the event loop from forcing an auto-zoom reset loop
                    this.isProcessingCrop = true;

                    fileInput.files = dataTransfer.files;
                    fileInput.dispatchEvent(new Event("change", { bubbles: true }));

                    // Safely release the lock after propagation finishes cleanly
                    setTimeout(() => {
                        this.isProcessingCrop = false;
                    }, 30);
                }
            }, "image/jpeg", 0.90);

        } catch (error) {
            // Passive catch block avoiding console overload during high frequency polling intervals
        }
    }
};

