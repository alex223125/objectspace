import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    // static targets = ["entries", "pagination"]
    static targets = ['entries', 'newFolderAdditionButton']

    initialize() {
        console.log("Dashboard Technologies controller initialized")
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
        console.log("Dashboard Technologies controller connected")
        // this.currentFolderId = ""
        // this.initialFolderId = ''
    }


    disconnect() {
        console.log("Dashboard Technologies controller disconnected")
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
        let url = `/search_technologies?target_user=${this.targetUser}`
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log(data)
                this.insertFoldersAndTechnologies(data)

                // this.setCurrentFolder(data.current_folder_id)
                // this.setPathForNewFolderAdditionButton()
                // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
            }
        })
    }

    insertFoldersAndTechnologies(data) {
        // DOC: remove results which was before and put fresh results
        this.entriesTarget.innerHTML = "";
        this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
    }

    // setCurrentFolder(folderId) {
    //     this.currentFolderId = folderId
    // }

    // setPathForNewFolderAdditionButton(){
    //     let path =`/folders/new?target_folder=${this.currentFolderId}`
    //     this.newFolderAdditionButtonTarget.href = path
    // }

    // processIntersectionEntries(entries) {
    //     entries.forEach(entry => {
    //         if (entry.isIntersecting) {
    //             this.loadMore()
    //         }
    //     })
    // }

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