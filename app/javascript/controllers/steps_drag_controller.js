import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
    connect() {
        console.log("Steps drag controller connected")
        this.sortable = Sortable.create(this.element, {
            group: 'shared',
            animation: 150,
            onEnd: this.end.bind(this),
            filter: ".nodraggable"
        })
    }


    recalculateIndexes(){
        // recount indexes
        var positionHiddenElemenets = $(".position-hidden-field")

        positionHiddenElemenets.each(function( index ) {
            $( this )[0].value = index + 1
        });

        // recount indexes 2
        var positionHiddenElemenets = $(".position-visible-field")
        positionHiddenElemenets.each(function( index ) {
            $( this ).text(index + 1)
        });
    }


    end(event) {
        this.recalculateIndexes()
        // let id = event.item.dataset.id
        // let data = new FormData()
        // console.log(data)
        // data.append("position", event.newIndex + 1)

        // put value in a position field

        // Rails.ajax({
        //     url: this.data.get("url").replace(":id", id),
        //     type: 'PATCH',
        //     data: data
        // })
    }
}