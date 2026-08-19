// import { Controller } from "@hotwired/stimulus"
//
// export default class extends Controller {
//     static targets = [
//         "board",
//         "status",
//         "submit",
//         "order"
//     ]
//
//     connect() {
//         this.selected = null
//         this.completed = false
//
//         this.readInitialOrder()
//     }
//
//     readInitialOrder() {
//         this.order = Array.from(
//             this.boardTarget.querySelectorAll("[data-puzzle-piece]")
//         ).map(element => Number(element.dataset.puzzlePiece))
//
//         this.updateHiddenValue()
//     }
//
//     select(event) {
//         if (this.completed) return
//
//         const piece = event.currentTarget
//         const index = Number(piece.dataset.index)
//
//         if (this.selected === null) {
//             this.selected = index
//
//             piece.classList.add(
//                 "ring-4",
//                 "ring-sky-300",
//                 "scale-105"
//             )
//
//             return
//         }
//
//         if (this.selected === index) {
//             this.clearSelection()
//             return
//         }
//
//         this.swap(this.selected, index)
//         this.clearSelection()
//         this.render()
//         this.check()
//     }
//
//     swap(first, second) {
//         const tmp = this.order[first]
//
//         this.order[first] = this.order[second]
//         this.order[second] = tmp
//     }
//
//     render() {
//         const pieces =
//             Array.from(
//                 this.boardTarget.querySelectorAll("[data-puzzle-piece]")
//             )
//
//         pieces.forEach((piece, index) => {
//             piece.dataset.puzzlePiece = this.order[index]
//             piece.dataset.index = index
//
//             piece.style.backgroundPosition =
//                 this.backgroundPosition(this.order[index])
//         })
//
//         this.updateHiddenValue()
//     }
//
//     backgroundPosition(piece) {
//         const row = Math.floor(piece / 3)
//         const column = piece % 3
//
//         return `${column * 50}% ${row * 50}%`
//     }
//
//     check() {
//         const solved =
//             this.order.every(
//                 (value, index) => value === index
//             )
//
//         if (!solved) {
//             this.statusTarget.textContent =
//                 "Arrange the image pieces to continue."
//
//             this.statusTarget.className =
//                 "text-xs font-bold text-slate-400"
//
//             return
//         }
//
//         this.completed = true
//
//         this.statusTarget.textContent =
//             "✓ Human verification complete"
//
//         this.statusTarget.className =
//             "text-xs font-black text-emerald-500"
//
//         this.submitTarget.disabled = false
//         this.submitTarget.classList.remove("opacity-50", "cursor-not-allowed")
//     }
//
//     updateHiddenValue() {
//         this.orderTarget.value =
//             JSON.stringify(this.order)
//     }
//
//     clearSelection() {
//         this.selected = null
//
//         this.boardTarget
//             .querySelectorAll("[data-puzzle-piece]")
//             .forEach(piece => {
//                 piece.classList.remove(
//                     "ring-4",
//                     "ring-sky-300",
//                     "scale-105"
//                 )
//             })
//     }
// }