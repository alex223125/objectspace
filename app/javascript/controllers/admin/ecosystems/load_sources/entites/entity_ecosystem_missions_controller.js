import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "level",
        "xp",
        "xpProgress",
        "streak",
        "missionList",
        "achievementList",
        "completionNotice"
    ]

    static values = {
        missions: Array,
        achievements: Array
    }

    connect() {
        this.storageKey =
            "ecosystem-gamification-progress"

        this.progress =
            this.loadProgress()

        this.render()
    }

    render() {
        this.renderProgress()
        this.renderMissions()
        this.renderAchievements()
    }

    defaultProgress() {
        return {
            xp: 0,
            completedMissions: [],
            unlockedAchievements: [],
            streak: 0,
            lastActivity: null
        }
    }

    loadProgress() {
        try {
            const raw =
                window.localStorage.getItem(
                    this.storageKey
                )

            if (!raw) {
                return this.defaultProgress()
            }

            const parsed =
                JSON.parse(raw)

            return {
                ...this.defaultProgress(),
                ...parsed
            }
        } catch (_error) {
            return this.defaultProgress()
        }
    }

    saveProgress() {
        try {
            window.localStorage.setItem(
                this.storageKey,
                JSON.stringify(this.progress)
            )
        } catch (_error) {
            // Local persistence is optional.
        }
    }

    renderProgress() {
        const xp =
            Number(this.progress.xp || 0)

        const level =
            this.calculateLevel(xp)

        const currentLevelXp =
            this.levelStartXp(level)

        const nextLevelXp =
            this.levelStartXp(level + 1)

        const progressXp =
            Math.max(
                0,
                xp - currentLevelXp
            )

        const requiredXp =
            Math.max(
                1,
                nextLevelXp - currentLevelXp
            )

        const percentage =
            Math.min(
                100,
                Math.round(
                    (progressXp / requiredXp) *
                    100
                )
            )

        if (this.hasLevelTarget) {
            this.levelTarget.textContent =
                level
        }

        if (this.hasXpTarget) {
            this.xpTarget.textContent =
                xp
        }

        if (this.hasXpProgressTarget) {
            this.xpProgressTarget.style.width =
                `${percentage}%`

            this.xpProgressTarget.setAttribute(
                "aria-valuenow",
                percentage
            )
        }

        if (this.hasStreakTarget) {
            this.streakTarget.textContent =
                this.progress.streak || 0
        }
    }

    calculateLevel(xp) {
        return Math.max(
            1,
            Math.floor(
                Math.sqrt(
                    Number(xp) / 100
                )
            ) + 1
        )
    }

    levelStartXp(level) {
        const normalizedLevel =
            Math.max(1, Number(level))

        return Math.pow(
            normalizedLevel - 1,
            2
        ) * 100
    }

    renderMissions() {
        if (!this.hasMissionListTarget) {
            return
        }

        const missions =
            Array.isArray(this.missionsValue)
                ? this.missionsValue
                : []

        if (missions.length === 0) {
            this.missionListTarget.innerHTML =
                this.emptyState(
                    "More missions are coming as your ecosystem grows."
                )

            return
        }

        this.missionListTarget.innerHTML =
            missions
                .map(mission =>
                    this.missionMarkup(
                        mission
                    )
                )
                .join("")
    }

    missionMarkup(mission) {
        const id =
            String(
                mission.id ||
                mission.key ||
                mission.name
            )

        const completed =
            this.progress.completedMissions
                .includes(id)

        const reward =
            Number(
                mission.xp ||
                mission.reward ||
                25
            )

        const description =
            mission.description ||
            "Explore the ecosystem to complete this mission."

        return `
      <article
        class="
          group
          relative
          overflow-hidden
          rounded-[24px]
          border-2
          ${
            completed
                ? "border-emerald-200 bg-emerald-50/50"
                : "border-orange-100 bg-white"
        }
          p-5
          shadow-sm
          transition-all
          duration-300
          ${
            completed
                ? ""
                : "hover:-translate-y-1 hover:border-orange-200 hover:shadow-md"
        }
        "
      >

        <div
          class="
            absolute
            right-0
            top-0
            h-20
            w-20
            rounded-bl-full
            ${
            completed
                ? "bg-emerald-100/60"
                : "bg-orange-50/70"
        }
          "
        ></div>

        <div
          class="
            relative
            flex
            items-start
            justify-between
            gap-4
          "
        >

          <div
            class="
              flex
              items-start
              gap-3
            "
          >

            <div
              class="
                flex
                h-11
                w-11
                shrink-0
                items-center
                justify-center
                rounded-2xl
                ${
            completed
                ? "bg-emerald-100 text-emerald-600"
                : "bg-orange-100 text-orange-600"
        }
                text-lg
                shadow-sm
              "
            >
              ${
            completed
                ? "✓"
                : mission.icon || "🎯"
        }
            </div>

            <div>

              <div
                class="
                  text-sm
                  font-black
                  text-slate-700
                "
              >
                ${this.escapeHtml(
            mission.name ||
            "Ecosystem mission"
        )}
              </div>

              <p
                class="
                  mt-1
                  max-w-xl
                  text-[11px]
                  leading-5
                  text-slate-400
                "
              >
                ${this.escapeHtml(
            description
        )}
              </p>

            </div>

          </div>

          <div
            class="
              shrink-0
              rounded-full
              ${
            completed
                ? "bg-emerald-100 text-emerald-600"
                : "bg-orange-50 text-orange-600"
        }
              px-3
              py-1.5
              text-[9px]
              font-black
              uppercase
              tracking-wider
            "
          >
            ${
            completed
                ? "Completed"
                : `+${reward} XP`
        }
          </div>

        </div>

        <div
          class="
            relative
            mt-4
            flex
            items-center
            justify-between
            gap-4
          "
        >

          <div
            class="
              text-[9px]
              font-black
              uppercase
              tracking-widest
              ${
            completed
                ? "text-emerald-500"
                : "text-orange-400"
        }
            "
          >
            ${
            completed
                ? "Mission complete"
                : "Next objective"
        }
          </div>

          ${
            completed
                ? `
                <span
                  class="
                    text-[10px]
                    font-black
                    text-emerald-600
                  "
                >
                  XP earned
                </span>
              `
                : `
                <button
                  type="button"
                  class="
                    rounded-xl
                    border
                    border-orange-200
                    bg-gradient-to-r
                    from-orange-400
                    to-amber-400
                    px-3
                    py-2
                    text-[10px]
                    font-black
                    text-white
                    shadow-sm
                    shadow-orange-200
                    transition
                    hover:-translate-y-0.5
                    hover:shadow-md
                  "
                  data-action="
                    click->entity-ecosystem-missions#completeMission
                  "
                  data-mission-id="${this.escapeHtml(id)}"
                  data-mission-xp="${reward}"
                >
                  Complete mission →
                </button>
              `
        }

        </div>

      </article>
    `
    }

    completeMission(event) {
        const button =
            event.currentTarget

        const missionId =
            String(
                button.dataset.missionId
            )

        const reward =
            Number(
                button.dataset.missionXp || 25
            )

        if (
            this.progress.completedMissions
                .includes(missionId)
        ) {
            return
        }

        this.progress.completedMissions.push(
            missionId
        )

        this.progress.xp += reward

        this.updateStreak()

        this.unlockAchievements()

        this.saveProgress()

        this.render()

        this.showCompletion(
            `Mission complete! +${reward} XP`
        )
    }

    updateStreak() {
        const today =
            new Date()
                .toISOString()
                .slice(0, 10)

        const previous =
            this.progress.lastActivity

        if (!previous) {
            this.progress.streak = 1
        } else if (
            previous === today
        ) {
            return
        } else {
            const previousDate =
                new Date(previous)

            const todayDate =
                new Date(today)

            const difference =
                Math.round(
                    (
                        todayDate -
                        previousDate
                    ) /
                    86400000
                )

            if (difference === 1) {
                this.progress.streak =
                    Number(
                        this.progress.streak || 0
                    ) + 1
            } else {
                this.progress.streak = 1
            }
        }

        this.progress.lastActivity =
            today
    }

    unlockAchievements() {
        const achievements =
            Array.isArray(
                this.achievementsValue
            )
                ? this.achievementsValue
                : []

        achievements.forEach(
            achievement => {
                const id =
                    String(
                        achievement.id ||
                        achievement.key ||
                        achievement.name
                    )

                if (
                    this.progress
                        .unlockedAchievements
                        .includes(id)
                ) {
                    return
                }

                const threshold =
                    Number(
                        achievement.xpThreshold ||
                        achievement.threshold ||
                        0
                    )

                const missionThreshold =
                    Number(
                        achievement.missionThreshold ||
                        0
                    )

                const xpUnlocked =
                    threshold > 0 &&
                    this.progress.xp >=
                    threshold

                const missionsUnlocked =
                    missionThreshold > 0 &&
                    this.progress
                        .completedMissions
                        .length >=
                    missionThreshold

                if (
                    xpUnlocked ||
                    missionsUnlocked
                ) {
                    this.progress
                        .unlockedAchievements
                        .push(id)

                    this.showCompletion(
                        `Achievement unlocked: ${
                            achievement.name
                        }`
                    )
                }
            }
        )
    }

    renderAchievements() {
        if (!this.hasAchievementListTarget) {
            return
        }

        const achievements =
            Array.isArray(
                this.achievementsValue
            )
                ? this.achievementsValue
                : []

        this.achievementListTarget.innerHTML =
            achievements
                .map(
                    achievement =>
                        this.achievementMarkup(
                            achievement
                        )
                )
                .join("")
    }

    achievementMarkup(
        achievement
    ) {
        const id =
            String(
                achievement.id ||
                achievement.key ||
                achievement.name
            )

        const unlocked =
            this.progress
                .unlockedAchievements
                .includes(id)

        return `
      <div
        class="
          flex
          min-h-[120px]
          flex-col
          items-center
          justify-center
          rounded-[22px]
          border-2
          ${
            unlocked
                ? "border-amber-200 bg-gradient-to-b from-amber-50 to-orange-50"
                : "border-slate-100 bg-slate-50/70"
        }
          p-4
          text-center
          transition-all
          duration-300
          ${
            unlocked
                ? "shadow-sm shadow-amber-100"
                : ""
        }
        "
      >

        <div
          class="
            flex
            h-12
            w-12
            items-center
            justify-center
            rounded-2xl
            ${
            unlocked
                ? "bg-amber-100 text-amber-600"
                : "bg-slate-100 text-slate-300"
        }
            text-xl
          "
        >
          ${
            unlocked
                ? achievement.icon || "🏆"
                : "🔒"
        }
        </div>

        <div
          class="
            mt-3
            text-[11px]
            font-black
            ${
            unlocked
                ? "text-amber-700"
                : "text-slate-400"
        }
          "
        >
          ${this.escapeHtml(
            achievement.name ||
            "Achievement"
        )}
        </div>

        <div
          class="
            mt-1
            text-[9px]
            leading-4
            ${
            unlocked
                ? "text-amber-500"
                : "text-slate-300"
        }
          "
        >
          ${this.escapeHtml(
            unlocked
                ? (
                    achievement.description ||
                    "Achievement unlocked."
                )
                : "Keep exploring to unlock."
        )}
        </div>

      </div>
    `
    }

    showCompletion(message) {
        if (!this.hasCompletionNoticeTarget) {
            return
        }

        const notice =
            this.completionNoticeTarget

        notice.textContent =
            message

        notice.classList.remove(
            "hidden"
        )

        notice.classList.add(
            "animate-pulse"
        )

        window.clearTimeout(
            this.completionTimeout
        )

        this.completionTimeout =
            window.setTimeout(() => {
                notice.classList.add(
                    "hidden"
                )

                notice.classList.remove(
                    "animate-pulse"
                )
            }, 3000)
    }

    emptyState(message) {
        return `
      <div
        class="
          rounded-[24px]
          border-2
          border-dashed
          border-slate-200
          bg-slate-50
          p-8
          text-center
          text-xs
          font-bold
          text-slate-400
        "
      >
        ${this.escapeHtml(message)}
      </div>
    `
    }

    escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;")
    }
}