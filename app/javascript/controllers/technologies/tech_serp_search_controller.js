import { Controller } from '@hotwired/stimulus'
// new name -  user_serp_controller + move to technologies folder

export default class extends Controller {
    // static targets = ["entries", "pagination"]
    static targets = ['newFolderAdditionButton', "allTab",

        "userAsTagInput",
        "tagInput",

        "searchInput",

        // original inputs
        "originalTagInput",
        // originalUsersAsTagsInput

        "searchTabs",

        // upper tabs
        "articlesTab",
        "methodsTab",
        "algorithmsTab",
        "classesTab",
        "frameworksTab",

        // tabs content
        "allMixedEntriesTab",
        "articlesEntriesTab",
        "methodsEntriesTab",
        "algorithmsEntriesTab",
        "classesEntriesTab",
        "frameworksEntriesTab",


        'allMixedEntries',
        "articlesEntries",
        "methodsEntries",
        "algorithmsEntries",
        "classesEntries",
        "frameworksEntries",

        //other controllrs
        "techSerpTagsInput"

    ]



    initialize() {
        console.log("Tecnologies serp serach controller initialized")


        // this.tags = ''
        this.searchType = ''

        this.technologiesPagination = ''
        this.articlesPagination = ''
        this.unitsPagination = ''
        this.algorithmsPagination = ''
        this.simple_classesPagination = ''
        this.frameworksPagination = ''

        this.loadMorePage = ''

        this.currentActiveTab = ""

        console.log(this.allTabTarget.innerHTML)
        Promise.resolve().then(() => {
            this.setInputValuesFromRedirect()
        })
    }

    addTagToTagsInput(tag) {
        const techSerpTagsInputController = this.application.getControllerForElementAndIdentifier(this.techSerpTagsInputTarget, "tech_serp_tags_input")
        techSerpTagsInputController.addTag(tag)
    }

    setInputValuesFromRedirect(){
        console.log("setInputValuesFromRedirect triggered")
        // set tags
        // let queryString = window.location.search;
        // let urlParams = new URLSearchParams(queryString);
        // var tag = urlParams.get('tags')

        // 1.Tags
        var paramsFromUrl = this.paramsFromUrl()
        var tags = paramsFromUrl.tags

        if (tags != null) {
            this.addTagToTagsInput(paramsFromUrl.tags)
        }

        // 2.Search input
        var searchQuery = paramsFromUrl.search_query
        if (searchQuery != null) {
            this.searchInputTarget.value = searchQuery
        }
    }



    connect() {
        console.log("Tecnologies serp serach controller connected")
        // this.setInputValuesFromRedirect()
        this.initialLoad()
    }


    disconnect() {
        console.log("Tecnologies serp serach controller disconnected")
    }

    submitSearch(){
        // 1 set type of search depending on active tab
        // this.setCurrentActiveTab()
        this.switchTabTo("mixed-results-tab")
        this.resetLoadMoreButtonsVisibility()
        this.resetSearchResultsContainers()
        this.resetPagination()
        this.setCurrentActiveTab()
        this.setTypeOfSearch()
        // 2 make request
        this.loadEntries("submit-search")
    }

    loadMore(){
        console.log("loadMore triggered!")
        // 1 define which tab is active
        this.setCurrentActiveTab()
        this.setTypeOfSearch()
        this.setNextPageParameter()

        console.log("this.checkIfNextPageExists()")
        console.log(this.checkIfNextPageExists())

        this.toggleLoadMoreButton("hide")
        if (this.checkIfNextPageExists()) {
            this.loadEntries("load-more")
        } else {
            // do nothing
            // this.hideLoadButton()
        }

    }

    // PRIVATE

    resetSearchResultsContainers() {
        this.allMixedEntriesTarget.innerHTML = ""
        this.articlesEntriesTarget.innerHTML = ""
        this.methodsEntriesTarget.innerHTML = ""
        this.algorithmsEntriesTarget.innerHTML = ""
        this.classesEntriesTarget.innerHTML = ""
        this.frameworksEntriesTarget.innerHTML = ""
    }

    resetLoadMoreButtonsVisibility() {
        var buttonClass = ".load-more-button"
        this.allMixedEntriesTabTarget.querySelector(buttonClass).style.display = 'none'
        this.articlesEntriesTabTarget.querySelector(buttonClass).style.display = 'none'
        this.methodsEntriesTabTarget.querySelector(buttonClass).style.display = 'none'
        this.algorithmsEntriesTabTarget.querySelector(buttonClass).style.display = 'none'
        this.classesEntriesTabTarget.querySelector(buttonClass).style.display = 'none'
        this.frameworksEntriesTabTarget.querySelector(buttonClass).style.display = 'none'
    }

    switchTabTo(tab){
        if (tab == "mixed-results-tab") {
            this.allTabTarget.click()
        }
    }

    resetPagination() {
        this.loadMorePage = ''
    }

    toggleLoadMoreButton(action){
        var spinnerSelector = ".load-more-button"
        var currentActiveTabId = this.currentActiveTab.id

        let displayStyle = ""
        if (action == "show"){
            displayStyle = ""
        } else if (action == "hide") {
            displayStyle = 'none'
        }

        if (currentActiveTabId == "mixed-results-tab") {
            this.allMixedEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "articles-tab") {
            this.articlesEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "methods-tab") {
            this.methodsEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "algorithms-tab") {
            this.algorithmsEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "classes-tab") {
            this.classesEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "frameworks-tab") {
            this.frameworksEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        }
    }

    toggleLoadSpinner(action){
        var spinnerSelector = ".loading-spinner"
        var currentActiveTabId = this.currentActiveTab.id

        let displayStyle = ""
        if (action == "show"){
            displayStyle = ""
        } else if (action == "hide") {
            displayStyle = 'none'
        }

        if (currentActiveTabId == "mixed-results-tab") {
            this.allMixedEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "articles-tab") {
            this.articlesEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "methods-tab") {
            this.methodsEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "algorithms-tab") {
            this.algorithmsEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "classes-tab") {
            this.classesEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        } else if (currentActiveTabId == "frameworks-tab") {
            this.frameworksEntriesTabTarget.querySelector(spinnerSelector).style.display = displayStyle
        }

    }


    checkIfNextPageExists(){
        if (this.searchType == 'mixed-search') {
            return this.loadMorePage <= this.technologiesPagination.pages
        } else if (this.searchType == 'articles-search') {
            return this.loadMorePage <= this.articlesPagination.pages
        } else if (this.searchType == 'methods-search') {
            return this.loadMorePage <= this.unitsPagination.pages
        } else if (this.searchType == 'algorithms-search') {
            return this.loadMorePage <= this.algorithmsPagination.pages
        } else if (this.searchType == 'classes-search') {
            return this.loadMorePage <= this.simple_classesPagination.pages
        } else if (this.searchType == 'frameworks-search') {
            return this.loadMorePage <= this.frameworksPagination.pages
        }
    }

    setNextPageParameter(){
        if (this.searchType == 'mixed-search') {
            console.log('this.technologiesPagination')
            console.log(this.technologiesPagination)
            this.loadMorePage = this.technologiesPagination.page + 1
        } else if (this.searchType == 'articles-search') {
            this.loadMorePage = this.articlesPagination.page + 1
        } else if (this.searchType == 'methods-search') {
            this.loadMorePage = this.unitsPagination.page + 1
        } else if (this.searchType == 'algorithms-search') {
            this.loadMorePage = this.algorithmsPagination.page + 1
        } else if (this.searchType == 'classes-search') {
            this.loadMorePage = this.simple_classesPagination.page + 1
        } else if (this.searchType == 'frameworks-search') {
            this.loadMorePage = this.frameworksPagination.page + 1
        }
    }

    setCurrentActiveTab(){
        this.currentActiveTab = this.searchTabsTarget.getElementsByClassName("active")[0]
        console.log("currentActiveTab")
        console.log(this.currentActiveTab)

        // when we initalizeng controller ui is not ready
        if (typeof this.currentActiveTab == 'undefined') {
            console.log("currentActiveTab default")
            this.currentActiveTab = this.allTabTarget
        }
    }

    setTypeOfSearch(){
        var currentActiveTabId = this.currentActiveTab.id
        if (currentActiveTabId == "mixed-results-tab") {
            this.searchType = 'mixed-search'
        } else if (currentActiveTabId == "articles-tab") {
            this.searchType = 'articles-search'
        } else if (currentActiveTabId == "methods-tab") {
            this.searchType = 'methods-search'
        } else if (currentActiveTabId == "algorithms-tab") {
            this.searchType = 'algorithms-search'
        } else if (currentActiveTabId == "classes-tab") {
            this.searchType = 'classes-search'
        } else if (currentActiveTabId == "frameworks-tab") {
            this.searchType = 'frameworks-search'
        }
    }


    loadEntries(action) {
        console.log("loadEntries triggered")

        this.toggleLoadSpinner("show")

        // build params
        var searchQuery = this.searchInputTarget.value
        console.log("searchQuery")
        console.log(searchQuery)

        let basicParams = `search_type=${this.searchType}`
        let totalParams = basicParams

        if (searchQuery == '') {
            totalParams = totalParams + `&search_query=no-query`
        } else {
            totalParams = totalParams + `&search_query=${searchQuery}`
        }

        var tags = this.tagsParams()
        // var tags = this.tagInputTarget.value
        if (tags != []) {
            console.log("tags")
            console.log(tags)
            // var tagsValue = JSON.parse( tags ).value()
            totalParams = totalParams + `&tags=${tags}`
        }

        // if (this.tags != '') {
        //     totalParams = totalParams + `&tags=${this.tags}`
        // }

        if (this.loadMorePage != '') {
            totalParams = totalParams + `&page=${this.loadMorePage}`
        } else {
            var defaultPage = 1
            totalParams = totalParams + `&page=${defaultPage}`
        }


        var selectedUsers = this.selectedUsersParams()
        if (selectedUsers != []) {
            totalParams = totalParams + `&users=${selectedUsers}`
        }

        console.log("totalParams")
        console.log(totalParams)

        let url = `/main_search_technologies?${totalParams}`

        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log(data)
                this.toggleLoadSpinner("hide")
                if (action == "submit-search") {
                    this.insertInitialSearchResults(data)
                    this.displayAllLoadMoreButtons()
                    this.setEntriesAmount(data)
                } else if (action == "load-more") {
                    this.insertSearchResults(data)
                }
                this.toggleLoadMoreButton("show")
                this.setPagination(data)

            }
        })
    }


    selectedUsersParams(){
        // convert users as tags
        var selectedUsers = []
        this.userAsTagInputTargets.map(tag => {
            selectedUsers.push($(tag).attr("value"));
        })
        return selectedUsers
    }

    tagsParams() {
        // convert tags
        var tags = []
        this.tagInputTargets.map(tag => {
            tags.push($(tag).attr("value"));
        })
        return tags
    }

    initialLoad(){
        console.log("initialLoad triggered")
        this.setCurrentActiveTab()
        this.initialLoadEntries()
    }

    paramsFromUrl(){
        let queryString = window.location.search;
        let urlParams = new URLSearchParams(queryString);
        let tags = urlParams.get('tags')
        let search_query = urlParams.get('search_query')
        let params = {tags: tags, search_query: search_query}
        return params
    }

    // searchQueryFromUrl(){
    //     let queryString = window.location.search;
    //     let urlParams = new URLSearchParams(queryString);
    //     let tags = urlParams.get('search_query')
    //     return tags
    // }

    initialLoadEntries() {
        this.toggleLoadSpinner("show")

        // Default values
        var initialSearchType = 'mixed-search'
        this.searchType = initialSearchType
        var defaultPage = 1

        // During initial load we take params from url,
        // not from the form
        let urlParams = this.paramsFromUrl()
        let tags = urlParams.tags
        let searchQuery = urlParams.search_query

        // Chaning parameters
        var params = `search_type=${this.searchType}&page=${defaultPage}`
        if (tags != null) {
            params = params + `&tags=${tags}`
        }
        if (searchQuery != null) {
            params = params + `&search_query=${searchQuery}`
        }
        let url = `/main_search_technologies?${params}`



        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log(data)
                this.toggleLoadSpinner("hide")
                this.insertInitialSearchResults(data)
                this.displayAllLoadMoreButtons()
                this.setEntriesAmount(data)
                this.setInitialPagination(data)
            }
        })
    }

    displayAllLoadMoreButtons() {
        var buttonClass = ".load-more-button"
        this.allMixedEntriesTabTarget.querySelector(buttonClass).style.display = ''
        this.articlesEntriesTabTarget.querySelector(buttonClass).style.display = ''
        this.methodsEntriesTabTarget.querySelector(buttonClass).style.display = ''
        this.algorithmsEntriesTabTarget.querySelector(buttonClass).style.display = ''
        this.classesEntriesTabTarget.querySelector(buttonClass).style.display = ''
        this.frameworksEntriesTabTarget.querySelector(buttonClass).style.display = ''
    }

    setInitialPagination(data){
        this.technologiesPagination = data.technologies_pagination
        this.articlesPagination = data.articles_pagination
        this.unitsPagination = data.units_pagination
        this.algorithmsPagination = data.algorithms_pagination
        this.simple_classesPagination = data.simple_classes_pagination
        this.frameworksPagination = data.frameworks_pagination
    }

    setPagination(data){
        console.log("asfasf")
        if (this.searchType == 'mixed-search') {
            console.log("this.technologiesPagination = this.data.technologies_pagination")
            this.technologiesPagination = data.technologies_pagination
        } else if (this.searchType == 'articles-search') {
            this.articlesPagination = data.articles_pagination
        } else if (this.searchType == 'methods-search') {
            this.unitsPagination = data.units_pagination
        } else if (this.searchType == 'algorithms-search') {
            this.algorithmsPagination = data.algorithms_pagination
        } else if (this.searchType == 'classes-search') {
            this.simple_classesPagination = data.simple_classes_pagination
        } else if (this.searchType == 'frameworks-search') {
            this.frameworksPagination = data.frameworks_pagination
        }
    }

    // first time we add results to all tabs, after that we do it by pagination
    insertInitialSearchResults(data) {
        this.allMixedEntriesTarget.insertAdjacentHTML('beforeend', data.all_mixed_entries)
        this.articlesEntriesTarget.insertAdjacentHTML('beforeend', data.articles_entries)
        this.methodsEntriesTarget.insertAdjacentHTML('beforeend', data.units_entries)
        this.algorithmsEntriesTarget.insertAdjacentHTML('beforeend', data.algorithms_entries)
        this.classesEntriesTarget.insertAdjacentHTML('beforeend', data.simple_classes_entries)
        this.frameworksEntriesTarget.insertAdjacentHTML('beforeend', data.frameworks_entries)
    }

    insertSearchResults(data) {
        if (this.searchType == 'mixed-search') {
            this.allMixedEntriesTarget.insertAdjacentHTML('beforeend', data.all_mixed_entries)
        } else if (this.searchType == 'articles-search'){
            console.log("Inserting articles-search")
            this.articlesEntriesTarget.insertAdjacentHTML('beforeend', data.articles_entries)
        } else if (this.searchType == 'methods-search'){
            console.log("Inserting methods-search")
            this.methodsEntriesTarget.insertAdjacentHTML('beforeend', data.units_entries)
        } else if (this.searchType == 'algorithms-search'){
            console.log("Inserting algorithms-search")
            this.algorithmsEntriesTarget.insertAdjacentHTML('beforeend', data.algorithms_entries)
        } else if (this.searchType == 'classes-search'){
            console.log("Inserting classes-search")
            this.classesEntriesTarget.insertAdjacentHTML('beforeend', data.simple_classes_entries)
        } else if (this.searchType == 'frameworks-search'){
            console.log("Inserting frameworks-search")
            this.frameworksEntriesTarget.insertAdjacentHTML('beforeend', data.frameworks_entries)
        }

    }


    setEntriesAmount(data) {
        if (this.searchType == 'mixed-search') {
            this.allTabTarget.innerHTML = `All (${data.entries_amount.technologies_count})`
            this.articlesTabTarget.innerHTML = `Articles (${data.entries_amount.articles_count})`
            this.methodsTabTarget.innerHTML = `Methods (${data.entries_amount.units_count})`
            this.algorithmsTabTarget.innerHTML = `Algorithms (${data.entries_amount.algorithms_count})`
            this.classesTabTarget.innerHTML = `Classes (${data.entries_amount.simple_classes_count})`
            this.frameworksTabTarget.innerHTML = `Frameworks (${data.entries_amount.frameworks_count})`
        }
    }

}