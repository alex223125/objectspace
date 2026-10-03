import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "level",
        "xp",
        "progress",
        "message",
        "achievement",
        "achievementTitle",
        "achievementDescription",
        "streak"
    ]

    static values = {
        total: {
            type: Number,
            default: 0
        },
        changes: {
            type: Number,
            default: 0
        },
        movements: {
            type: Number,
            default: 0
        },
        additions: {
            type: Number,
            default: 0
        },
        removals: {
            type: Number,
            default: 0
        },
        warnings: {
            type: Number,
            default: 0
        }
    }

    connect() {
        this.calculateProgress()
    }

    calculateProgress() {
        const xp =
            this.calculateXp()

        const level =
            this.calculateLevel(xp)

        const currentLevelXp =
            this.levelBaseXp(level)

        const nextLevelXp =
            this.levelBaseXp(level + 1)

        const progressRange =
            nextLevelXp -
            currentLevelXp

        const progress =
            progressRange <= 0
                ? 100
                : Math.min(
                    100,
                    Math.max(
                        0,
                        (
                            (
                                xp -
                                currentLevelXp
                            ) /
                            progressRange
                        ) *
                        100
                    )
                )

        if (this.hasLevelTarget) {
            this.levelTarget.textContent =
                `LEVEL ${level}`
        }

        if (this.hasXpTarget) {
            this.xpTarget.textContent =
                `${xp} XP`
        }

        if (this.hasProgressTarget) {
            this.progressTarget.style.width =
                `${progress}%`

            this.progressTarget.setAttribute(
                "aria-valuenow",
                Math.round(progress).toString()
            )
        }

        this.updateMessage(level)
        this.updateAchievement()
        this.updateStreak()
    }

    calculateXp() {
        return (
            this.totalValue * 10 +
            this.changesValue * 15 +
            this.movementsValue * 20 +
            this.additionsValue * 12 +
            this.removalsValue * 12 +
            this.warningsValue * 5
        )
    }

    calculateLevel(xp) {
        if (xp >= 1000) {
            return 10
        }

        if (xp >= 750) {
            return 9
        }

        if (xp >= 550) {
            return 8
        }

        if (xp >= 400) {
            return 7
        }

        if (xp >= 280) {
            return 6
        }

        if (xp >= 190) {
            return 5
        }

        if (xp >= 120) {
            return 4
        }

        if (xp >= 70) {
            return 3
        }

        if (xp >= 30) {
            return 2
        }

        return 1
    }

    levelBaseXp(level) {
        const levels = {
            1: 0,
            2: 30,
            3: 70,
            4: 120,
            5: 190,
            6: 280,
            7: 400,
            8: 550,
            9: 750,
            10: 1000
        }

        return levels[level] || 1000
    }

    updateMessage(level) {
        if (!this.hasMessageTarget) {
            return
        }

        const messages = {
            1: "Begin your comparison journey.",
            2: "You are discovering meaningful changes.",
            3: "Your comparison skills are growing.",
            4: "You are uncovering deeper ecosystem patterns.",
            5: "Advanced comparison explorer unlocked.",
            6: "You are mapping ecosystem evolution.",
            7: "Expert-level comparison activity detected.",
            8: "You are exploring complex ecosystem change.",
            9: "Master explorer status is approaching.",
            10: "Ecosystem Master level reached."
        }

        this.messageTarget.textContent =
            messages[level] ||
            messages[1]
    }

    updateAchievement() {
        if (!this.hasAchievementTarget) {
            return
        }

        let title =
            "First comparison"

        let description =
            "Start exploring differences between versions."

        if (this.movementsValue >= 1) {
            title = "Pattern Hunter"
            description =
                "You discovered a semantic movement."
        }

        if (this.additionsValue >= 3) {
            title = "Discovery Scout"
            description =
                "You uncovered multiple newly added entities."
        }

        if (this.removalsValue >= 3) {
            title = "Change Detective"
            description =
                "You identified several removed entities."
        }

        if (this.warningsValue >= 2) {
            title = "Identity Guardian"
            description =
                "You detected multiple identity warnings."
        }

        if (this.totalValue >= 10) {
            title = "Deep Explorer"
            description =
                "You explored a substantial comparison."
        }

        if (this.hasAchievementTitleTarget) {
            this.achievementTitleTarget.textContent =
                title
        }

        if (this.hasAchievementDescriptionTarget) {
            this.achievementDescriptionTarget.textContent =
                description
        }

        this.achievementTarget.hidden =
            false
    }

    updateStreak() {
        if (!this.hasStreakTarget) {
            return
        }

        const intensity =
            Math.min(
                7,
                Math.max(
                    1,
                    Math.ceil(
                        this.totalValue / 3
                    )
                )
            )

        this.streakTarget.textContent =
            `${intensity} discovery ${intensity === 1 ? "step" : "steps"}`
    }
}