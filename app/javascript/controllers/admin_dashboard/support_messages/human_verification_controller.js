// ============================================================
// FILE:
// app/javascript/controllers/human_verification_controller.js
//
// PURPOSE:
// Human verification puzzle.
//
// FEATURES:
// - Loads a different high-quality test image each time
// - Randomizes the puzzle hole position
// - Randomizes the puzzle vertical position
// - Prevents browser caching from reusing the same image URL
// - Uses Picsum Photos for test images
// ============================================================

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    // ==========================================================
    // STIMULUS TARGETS
    // ==========================================================

    static targets = [
        "openButton",
        "modal",
        "dialog",
        "puzzle",
        "background",
        "hole",
        "piece",
        "slider",
        "status",
        "error",
        "puzzleSuccess",
        "success",
        "token"
    ]


    // ==========================================================
    // STIMULUS VALUES
    // ==========================================================

    static values = {
        success: Boolean
    }


    // ==========================================================
    // CONNECT
    // ==========================================================

    connect() {

        this.successValue = false

        this.puzzleWidth = 64

        this.maxPosition = 0

        this.targetPosition = 0

        this.targetTop = 0

        this.currentImageUrl = null

        this.reset()

        this.boundKeydown =
            this.handleKeydown.bind(this)

        document.addEventListener(
            "keydown",
            this.boundKeydown
        )

        console.log(
            "human_verification_controller.js CONNECTED"
        )
    }


    // ==========================================================
    // DISCONNECT
    // ==========================================================

    disconnect() {

        document.removeEventListener(
            "keydown",
            this.boundKeydown
        )
    }


    // ==========================================================
    // OPEN PUZZLE
    // ==========================================================

    open() {

        /*
         * Open the modal first.
         *
         * This is important because the puzzle needs
         * a real width/height before calculating positions.
         */

        this.modalTarget.classList.remove(
            "hidden"
        )

        this.modalTarget.classList.add(
            "flex"
        )

        document.body.classList.add(
            "overflow-hidden"
        )


        /*
         * Wait for the browser to render the modal.
         */

        requestAnimationFrame(() => {

            this.generatePuzzle()

        })
    }


    // ==========================================================
    // CLOSE PUZZLE
    // ==========================================================

    close() {

        this.modalTarget.classList.remove(
            "flex"
        )

        this.modalTarget.classList.add(
            "hidden"
        )

        document.body.classList.remove(
            "overflow-hidden"
        )
    }


    // ==========================================================
    // ESCAPE KEY
    // ==========================================================

    handleKeydown(event) {

        if (
            event.key === "Escape" &&
            !this.modalTarget.classList.contains(
                "hidden"
            )
        ) {

            this.close()

        }
    }


    // ==========================================================
    // GENERATE PUZZLE
    // ==========================================================

    generatePuzzle() {

        if (!this.hasPuzzleTarget) {
            return
        }

        const width =
            this.puzzleTarget.clientWidth

        const height =
            this.puzzleTarget.clientHeight


        if (
            width <= 0 ||
            height <= 0
        ) {

            return

        }


        // ======================================================
        // 1. LOAD A DIFFERENT IMAGE
        // ======================================================

        this.loadRandomImage(
            width,
            height
        )


        // ======================================================
        // 2. CALCULATE PUZZLE PIECE SIZE
        // ======================================================

        const pieceSize =
            Math.min(
                72,
                Math.floor(
                    width * 0.16
                )
            )

        this.puzzleWidth =
            pieceSize


        // ======================================================
        // 3. MAXIMUM SLIDER POSITION
        // ======================================================

        this.maxPosition =
            Math.max(
                0,
                width -
                pieceSize -
                8
            )


        // ======================================================
        // 4. RANDOM HORIZONTAL TARGET
        // ======================================================

        const minimum =
            Math.floor(
                width * 0.30
            )

        const maximum =
            Math.floor(
                width * 0.78
            )

        this.targetPosition =
            Math.floor(
                minimum +
                Math.random() *
                Math.max(
                    1,
                    maximum -
                    minimum
                )
            )


        // ======================================================
        // 5. RANDOM VERTICAL TARGET
        // ======================================================

        const topMinimum =
            Math.floor(
                height * 0.20
            )

        const topMaximum =
            Math.floor(
                height * 0.65
            )

        this.targetTop =
            Math.floor(
                topMinimum +
                Math.random() *
                Math.max(
                    1,
                    topMaximum -
                    topMinimum
                )
            )


        // ======================================================
        // 6. HOLE
        // ======================================================

        this.holeTarget.style.width =
            `${pieceSize}px`

        this.holeTarget.style.height =
            `${pieceSize}px`

        this.holeTarget.style.left =
            `${this.targetPosition}px`

        this.holeTarget.style.top =
            `${this.targetTop}px`


        // ======================================================
        // 7. PUZZLE PIECE
        // ======================================================

        this.pieceTarget.style.width =
            `${pieceSize}px`

        this.pieceTarget.style.height =
            `${pieceSize}px`

        this.pieceTarget.style.left =
            "0px"

        this.pieceTarget.style.top =
            `${this.targetTop}px`


        /*
         * The piece uses the same image as the background.
         *
         * The background is shifted so that the portion
         * underneath the target hole appears inside the piece.
         */

        this.pieceTarget.style.backgroundImage =
            `url("${this.currentImageUrl}")`

        this.pieceTarget.style.backgroundSize =
            `${width}px ${height}px`

        this.pieceTarget.style.backgroundPosition =
            `-${this.targetPosition}px -${this.targetTop}px`


        // ======================================================
        // 8. RESET SLIDER
        // ======================================================

        this.sliderTarget.value = 0


        // ======================================================
        // 9. RESET UI
        // ======================================================

        this.clearError()

        this.statusTarget.textContent =
            "Drag the slider"


        this.statusTarget.classList.remove(
            "text-emerald-500"
        )

        this.statusTarget.classList.add(
            "text-slate-400"
        )


        this.puzzleSuccessTarget.classList.add(
            "hidden"
        )

        this.puzzleSuccessTarget.classList.remove(
            "flex"
        )


        this.successValue = false

    }


    // ==========================================================
    // LOAD RANDOM PICSUM IMAGE
    // ==========================================================

// ============================================================
// LOAD RANDOM TEST IMAGE
// ============================================================

    loadRandomImage(width, height) {

        /*
         * Unique URL every time.
         *
         * The timestamp/random value prevents the browser
         * from reusing a previously loaded puzzle image.
         */

        const cacheBuster =
            `${Date.now()}-${Math.random()}`
                .replace(".", "")


        /*
         * Random Image API.
         *
         * The image is requested at 1600 x 900.
         */

        this.currentImageUrl =
            `https://random.imagecdn.app/1600/900?random=${cacheBuster}`


        /*
         * Load the new image into the puzzle background.
         */

        this.backgroundTarget.src =
            this.currentImageUrl


        /*
         * Once the image has loaded, use exactly the same
         * image for the movable puzzle piece.
         */

        this.backgroundTarget.onload = () => {

            this.pieceTarget.style.backgroundImage =
                `url("${this.currentImageUrl}")`

        }
    }


    // ==========================================================
    // SLIDER MOVEMENT
    // ==========================================================

    move(event) {

        if (this.successValue) {
            return
        }

        const value =
            Number(
                event.target.value
            )

        const position =
            this.sliderToPosition(
                value
            )

        this.pieceTarget.style.left =
            `${position}px`

        this.statusTarget.textContent =
            `${Math.round(value)}%`
    }


    // ==========================================================
    // CONVERT SLIDER VALUE TO PIXEL POSITION
    // ==========================================================

    sliderToPosition(value) {

        return (
            (value / 100) *
            this.maxPosition
        )
    }


    // ==========================================================
    // VERIFY PUZZLE
    // ==========================================================

    check() {

        if (this.successValue) {
            return
        }

        const value =
            Number(
                this.sliderTarget.value
            )

        const position =
            this.sliderToPosition(
                value
            )

        const difference =
            Math.abs(
                position -
                this.targetPosition
            )


        /*
         * Allow a small amount of movement.
         */

        const tolerance = 14


        if (
            difference <= tolerance
        ) {

            this.verificationSucceeded()

        } else {

            this.verificationFailed()

        }
    }


    // ==========================================================
    // SUCCESS
    // ==========================================================

    verificationSucceeded() {

        this.successValue = true

        this.statusTarget.textContent =
            "Verified ✓"


        this.statusTarget.classList.remove(
            "text-slate-400"
        )

        this.statusTarget.classList.add(
            "text-emerald-500"
        )


        this.puzzleSuccessTarget.classList.remove(
            "hidden"
        )

        this.puzzleSuccessTarget.classList.add(
            "flex"
        )


        /*
         * Generate temporary browser-side token.
         *
         * IMPORTANT:
         * This is NOT cryptographic anti-bot protection.
         *
         * Your Rails backend should eventually issue
         * and validate a server-side challenge.
         */

        if (this.hasTokenTarget) {

            this.tokenTarget.value =
                this.createBrowserToken()

        }


        // ======================================================
        // CLOSE AFTER SUCCESS
        // ======================================================

        window.setTimeout(() => {

            this.close()


            if (
                this.hasOpenButtonTarget
            ) {

                this.openButtonTarget.classList.add(
                    "hidden"
                )

            }


            if (
                this.hasSuccessTarget
            ) {

                this.successTarget.classList.remove(
                    "hidden"
                )

            }

        }, 900)
    }


    // ==========================================================
    // FAILED
    // ==========================================================

    verificationFailed() {

        this.errorTarget.classList.remove(
            "hidden"
        )

        this.statusTarget.textContent =
            "Try again"


        this.dialogTarget.classList.remove(
            "human-verification-shake"
        )


        void this.dialogTarget.offsetWidth


        this.dialogTarget.classList.add(
            "human-verification-shake"
        )


        window.setTimeout(() => {

            this.resetPuzzlePosition()

        }, 500)
    }


    // ==========================================================
    // RESET
    // ==========================================================

    reset() {

        this.successValue = false


        if (
            this.hasSliderTarget
        ) {

            this.sliderTarget.value = 0

        }


        if (
            this.hasTokenTarget
        ) {

            this.tokenTarget.value = ""

        }


        if (
            this.hasSuccessTarget
        ) {

            this.successTarget.classList.add(
                "hidden"
            )

        }


        if (
            this.hasOpenButtonTarget
        ) {

            this.openButtonTarget.classList.remove(
                "hidden"
            )

        }


        if (
            this.hasErrorTarget
        ) {

            this.errorTarget.classList.add(
                "hidden"
            )

        }


        if (
            this.hasStatusTarget
        ) {

            this.statusTarget.textContent =
                "Drag the slider"


            this.statusTarget.classList.remove(
                "text-emerald-500"
            )

            this.statusTarget.classList.add(
                "text-slate-400"
            )

        }


        if (
            this.hasPuzzleSuccessTarget
        ) {

            this.puzzleSuccessTarget.classList.add(
                "hidden"
            )

            this.puzzleSuccessTarget.classList.remove(
                "flex"
            )

        }
    }


    // ==========================================================
    // RESET PUZZLE POSITION
    // ==========================================================

    resetPuzzlePosition() {

        if (
            !this.hasSliderTarget
        ) {

            return

        }


        this.sliderTarget.value = 0


        this.pieceTarget.style.left =
            "0px"


        this.clearError()


        this.statusTarget.textContent =
            "Drag the slider"
    }


    // ==========================================================
    // CLEAR ERROR
    // ==========================================================

    clearError() {

        if (
            !this.hasErrorTarget
        ) {

            return

        }


        this.errorTarget.classList.add(
            "hidden"
        )
    }


    // ==========================================================
    // CREATE TEMPORARY TOKEN
    // ==========================================================

    createBrowserToken() {

        const random =
            new Uint8Array(24)


        window.crypto.getRandomValues(
            random
        )


        return Array.from(
            random,
            byte =>
                byte
                    .toString(16)
                    .padStart(
                        2,
                        "0"
                    )
        ).join("")
    }

}