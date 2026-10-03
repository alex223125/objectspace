evolutionSelected(event) {
    const {
        versionId,
        versionLabel,
        changeCount
    } = event.detail

    console.debug(
        "[Comparison Intelligence] Evolution version selected",
        {
            versionId,
            versionLabel,
            changeCount
        }
    )

    /*
     * This event intentionally does not hard-code your application's
     * version URL.
     *
     * Later this controller can:
     *
     * 1. load the selected version
     * 2. replace the detailed diff
     * 3. update intelligence metrics
     * 4. update review progress
     * 5. update XP
     * 6. update generated insights
     * 7. update the URL
     *
     * without changing the timeline component.
     */
}