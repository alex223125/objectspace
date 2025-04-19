import { Controller } from '@hotwired/stimulus'
// in use?

export default class extends Controller {
    // static targets = ["entries", "pagination"]
    static targets = ['entries', 'newFolderAdditionButton']


    initialize() {
        console.log("Reports Repository items controller initialized")
        this.initialRepositoryId = ''

        this.setInitialRepository()
        // this.setPathForNewFolderAdditionButton()

        this.initialLoad()
        // let options = {
        //     rootMargin: '200px',
        // }
        //
        // this.intersectionObserver = new IntersectionObserver(entries => this.processIntersectionEntries(entries), options)
    }

    connect() {
        console.log("Reports Repository items controller connected")
        // this.username = ''
    }


    disconnect() {
        console.log("Reports Repository items controller disconnected")
    }

    // PRIVATE

    setInitialRepository(){
        // let queryString = window.location.search;
        // let urlParams = new URLSearchParams(queryString);
        // this.initialFolderId = urlParams.get('current_folder')
        // ['http:', '', '127.0.0.1:3000', 'username-sdfsdf-33-aaaa', '12']
        // http://127.0.0.1:3000/username-sdfsdf-33-aaaa/folder/12
        this.initialReportsRepositoryId = window.location.href.split('/')[5]
        // this.username = window.location.href.split('/')[3]
    }

    initialLoad() {
        console.log("initialLoad triggered")
        // let url = `/${this.username}/folder/${this.initialFolderId}`

        let url = '/search_reports'
        let params = `target=${this.initialReportsRepositoryId}&target_type=reports_repository`
        let path = `${url}?${params}`
        // if (this.initialFolderId != '' && this.initialFolderId != null) {
        //     console.log("11111")
        //     url = `/search_technologies?target_folder=${this.initialFolderId}`
        // } else {
        //     console.log("22222")
        //     url = '/technologies'
        // }

        // TODO: add load animation
        Rails.ajax({
            type: 'GET',
            url: path,
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
        this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
    }

    // setCurrentFolder(folderId) {
    //     this.currentFolderId = folderId
    // }

    // setPathForNewFolderAdditionButton(){
    //     let path =`/folders/new`
    //     let params = `target=${this.initialRepositoryId}&target_type='repository'`
    //     let totalPath = `${path}?${params}`
    //     this.newFolderAdditionButtonTarget.href = totalPath
    // }

    // processIntersectionEntries(entries) {
    //     entries.forEach(entry => {
    //         if (entry.isIntersecting) {
    //             this.loadMore()
    //         }
    //     })
    // }

    // loadMore() {
    //     let next_page = this.paginationTarget.querySelector("a[rel='next']")
    //     if (next_page == null) { return }
    //     let url = next_page.href
    //
    //     Rails.ajax({
    //         type: 'GET',
    //         url: url,
    //         dataType: 'json',
    //         success: (data) => {
    //             this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
    //             this.paginationTarget.innerHTML = data.pagination
    //         }
    //     })
    // }



}