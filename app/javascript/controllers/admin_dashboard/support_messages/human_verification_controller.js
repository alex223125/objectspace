// ============================================================
// FILE:
// app/javascript/controllers/admin_dashboard/support_messages/
// human_verification_controller.js
// ============================================================

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
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

    static values = {
        success: {
            type: Boolean,
            default: false
        }
    }

    connect() {
        console.log(
            "[human_verification] CONNECTED"
        )

        this.puzzleWidth = 64
        this.maxPosition = 0
        this.targetPosition = 0

        this.reset()

        this.boundKeydown =
            this.handleKeydown.bind(this)

        document.addEventListener(
            "keydown",
            this.boundKeydown
        )
    }

    disconnect() {
        document.removeEventListener(
            "keydown",
            this.boundKeydown
        )
    }

    // ==========================================================
    // OPEN
    // ==========================================================

    open() {
        console.log(
            "[human_verification] OPEN"
        )

        if (!this.hasModalTarget) {
            console.error(
                "[human_verification] Missing modal target"
            )

            return
        }

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
         * The modal is now visible, so the puzzle
         * has a real width/height.
         */
        requestAnimationFrame(() => {
            this.generatePuzzle()
        })
    }

    // ==========================================================
    // CLOSE
    // ==========================================================

    close() {
        if (!this.hasModalTarget) {
            return
        }

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
            this.hasModalTarget &&
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
        if (
            !this.hasPuzzleTarget ||
            !this.hasBackgroundTarget ||
            !this.hasHoleTarget ||
            !this.hasPieceTarget ||
            !this.hasSliderTarget
        ) {
            console.error(
                "[human_verification] Missing puzzle targets"
            )

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
            console.warn(
                "[human_verification] Puzzle has no dimensions yet"
            )

            return
        }

        const pieceSize =
            Math.min(
                64,
                Math.floor(width * 0.16)
            )

        this.puzzleWidth =
            pieceSize

        this.maxPosition =
            Math.max(
                0,
                width -
                pieceSize -
                8
            )

        /*
         * Keep the target away from the
         * extreme edges.
         */

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

        const top =
            Math.floor(
                height * 0.25 +
                Math.random() *
                Math.max(
                    1,
                    height * 0.45
                )
            )

        // --------------------------------------------------------
        // HOLE
        // --------------------------------------------------------

        this.holeTarget.style.width =
            `${pieceSize}px`

        this.holeTarget.style.height =
            `${pieceSize}px`

        this.holeTarget.style.left =
            `${this.targetPosition}px`

        this.holeTarget.style.top =
            `${top}px`

        // --------------------------------------------------------
        // PUZZLE PIECE
        // --------------------------------------------------------

        this.pieceTarget.style.width =
            `${pieceSize}px`

        this.pieceTarget.style.height =
            `${pieceSize}px`

        this.pieceTarget.style.left =
            "0px"

        this.pieceTarget.style.top =
            `${top}px`

        this.pieceTarget.style.backgroundImage =
            `url("${this.backgroundTarget.src}")`

        this.pieceTarget.style.backgroundSize =
            `${width}px ${height}px`

        this.pieceTarget.style.backgroundPosition =
            `-${this.targetPosition}px -${top}px`

        // --------------------------------------------------------
        // RESET SLIDER
        // --------------------------------------------------------

        this.sliderTarget.value = 0

        this.clearError()

        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                "Drag the slider"

            this.statusTarget.classList.remove(
                "text-emerald-500"
            )

            this.statusTarget.classList.add(
                "text-slate-400"
            )
        }

        if (this.hasPuzzleSuccessTarget) {
            this.puzzleSuccessTarget.classList.add(
                "hidden"
            )

            this.puzzleSuccessTarget.classList.remove(
                "flex"
            )
        }
    }

    // ==========================================================
    // SLIDER MOVEMENT
    // ==========================================================

    move(event) {
        if (
            this.successValue
        ) {
            return
        }

        if (
            !this.hasPieceTarget ||
            !this.hasStatusTarget
        ) {
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
    // SLIDER → PIXEL POSITION
    // ==========================================================

    sliderToPosition(value) {
        return (
            (value / 100) *
            this.maxPosition
        )
    }

    // ==========================================================
    // CHECK PUZZLE
    // ==========================================================

    check() {
        console.log(
            "[human_verification] CHECK"
        )

        if (
            this.successValue
        ) {
            return
        }

        if (
            !this.hasSliderTarget
        ) {
            console.error(
                "[human_verification] Missing slider target"
            )

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

        const tolerance = 12

        console.log({
            value: value,
            position: position,
            targetPosition:
            this.targetPosition,
            difference:
            difference
        })

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
        console.log(
            "[human_verification] SUCCESS"
        )

        this.successValue = true

        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                "Verified ✓"

            this.statusTarget.classList.remove(
                "text-slate-400"
            )

            this.statusTarget.classList.add(
                "text-emerald-500"
            )
        }

        if (this.hasPuzzleSuccessTarget) {
            this.puzzleSuccessTarget.classList.remove(
                "hidden"
            )

            this.puzzleSuccessTarget.classList.add(
                "flex"
            )
        }

        // ========================================================
        // IMPORTANT FIX
        //
        // Do NOT blindly call this.tokenTarget.
        // First verify that the target exists.
        // ========================================================

        if (
            this.hasTokenTarget
        ) {
            this.tokenTarget.value =
                this.createBrowserToken()

            console.log(
                "[human_verification] Token created"
            )
        } else {
            console.error(
                "[human_verification] TOKEN TARGET IS MISSING"
            )

            /*
             * Do not crash the whole controller.
             */
        }

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
        console.log(
            "[human_verification] FAILED"
        )

        if (
            this.hasErrorTarget
        ) {
            this.errorTarget.classList.remove(
                "hidden"
            )
        }

        if (
            this.hasStatusTarget
        ) {
            this.statusTarget.textContent =
                "Try again"
        }

        if (
            this.hasDialogTarget
        ) {
            this.dialogTarget.classList.remove(
                "human-verification-shake"
            )

            void this.dialogTarget.offsetWidth

            this.dialogTarget.classList.add(
                "human-verification-shake"
            )
        }

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

        if (
            this.hasPieceTarget
        ) {
            this.pieceTarget.style.left =
                "0px"
        }

        this.clearError()

        if (
            this.hasStatusTarget
        ) {
            this.statusTarget.textContent =
                "Drag the slider"
        }
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
    // CREATE BROWSER TOKEN
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
                    .padStart(2, "0")
        ).join("")
    }
}