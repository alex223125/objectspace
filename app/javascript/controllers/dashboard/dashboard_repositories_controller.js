import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    // static targets = ["entries", "pagination"]
    static targets = ['entries', 'newFolderAdditionButton']

    initialize() {
        console.log("Dashboard repositories controller initialized")
        this.targetUser = ''
        this.setInitialFolder()
        this.initialLoad()
        // let options = {
        //     rootMargin: '200px',
        // }
        //
        // this.intersectionObserver = new IntersectionObserver(entries => this.processIntersectionEntries(entries), options)
    }

    connect() {
        console.log("Dashboard repositories controller connected")
    }


    disconnect() {
        console.log("Dashboard repositories controller disconnected")
    }

    // PRIVATE

    setInitialFolder(){
        // let queryString = window.location.search;
        // let urlParams = new URLSearchParams(queryString);
        // this.initialFolderId = urlParams.get('current_folder')
        // ['http:', '', '127.0.0.1:3000', 'username-sdfsdf-33-aaaa', '12']
        // this.initialFolderId = window.location.href.split('/')[4]
        this.targetUser = window.location.href.split('/')[3]
    }

    initialLoad() {
        console.log("initialLoad triggered")
        // let next_page = this.paginationTarget.querySelector("a[rel='next']")
        // if (next_page == null) { return }
        // let url = next_page.href

        // let url = next_page.href

        // let url = ''
        // // if (this.initialFolderId != '' && this.initialFolderId != null) {
        // //     console.log("11111")
        //     url = `/technologies?target_user=${this.targetUser}`
        // // } else {
        // //     console.log("22222")
        // //     url = '/technologies'
        // // }


        // TODO: add auth key
        let url = `/dashboard/repositories?target_user=${this.targetUser}`
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log(data)
                this.insertRepositories(data)
            }
        })
    }

    insertRepositories(data) {
        this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
    }

    loadMore() {
        let next_page = this.paginationTarget.querySelector("a[rel='next']")
        if (next_page == null) { return }
        let url = next_page.href

        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                this.paginationTarget.innerHTML = data.pagination
            }
        })
    }



}