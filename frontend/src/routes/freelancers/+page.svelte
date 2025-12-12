<script lang="ts">
    import { onMount } from "svelte";
    import { api, type User } from "$lib/api";

    let freelancers: User[] = [];
    let isLoading = true;
    let searchQuery = "";
    let selectedSkills: string[] = [];
    let currentPage = 1;
    let totalPages = 1;

    const popularSkills = [
        "React",
        "Node.js",
        "Python",
        "Ruby on Rails",
        "UI/UX Design",
        "JavaScript",
        "TypeScript",
        "AWS",
        "Mobile Development",
        "Svelte",
    ];

    onMount(() => {
        loadFreelancers();
    });

    async function loadFreelancers() {
        isLoading = true;
        const params: Record<string, string | string[]> = {
            page: currentPage.toString(),
            per_page: "12",
        };

        if (searchQuery) params.q = searchQuery;
        if (selectedSkills.length > 0) params.skill = selectedSkills;

        const result = await api.searchFreelancers(params);
        if (result.data) {
            freelancers = result.data.freelancers;
            totalPages = result.data.meta.total_pages;
        }
        isLoading = false;
    }

    function toggleSkill(skill: string) {
        const normalized = skill.toLowerCase().replace(/ /g, "-");
        if (selectedSkills.includes(normalized)) {
            selectedSkills = selectedSkills.filter((s) => s !== normalized);
        } else {
            selectedSkills = [...selectedSkills, normalized];
        }
        currentPage = 1;
        loadFreelancers();
    }

    function handleSearch() {
        currentPage = 1;
        loadFreelancers();
    }

    function handleKeydown(e: KeyboardEvent) {
        if (e.key === "Enter") handleSearch();
    }

    function clearFilters() {
        selectedSkills = [];
        loadFreelancers();
    }

    function prevPage() {
        currentPage = Math.max(1, currentPage - 1);
        loadFreelancers();
    }

    function nextPage() {
        currentPage = Math.min(totalPages, currentPage + 1);
        loadFreelancers();
    }
</script>

<svelte:head>
    <title>Find Talent - NomadHire</title>
    <meta
        name="description"
        content="Find talented freelancers for your projects. Browse profiles and hire the best professionals worldwide."
    />
</svelte:head>

<div class="bg-gradient-to-br from-slate-50 to-primary-50/30 min-h-screen">
    <!-- Header -->
    <div class="bg-white border-b border-slate-100">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <h1 class="text-3xl font-display font-bold text-slate-900 mb-2">
                Find Talent
            </h1>
            <p class="text-slate-600">
                Discover skilled freelancers for your next project
            </p>

            <!-- Search -->
            <div class="mt-6 flex gap-4">
                <div class="flex-1 relative">
                    <svg
                        class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                        />
                    </svg>
                    <input
                        type="text"
                        bind:value={searchQuery}
                        on:keydown={handleKeydown}
                        placeholder="Search freelancers by name or skills..."
                        class="input pl-12"
                    />
                </div>
                <button on:click={handleSearch} class="btn-primary">
                    Search
                </button>
            </div>
        </div>
    </div>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="flex flex-col lg:flex-row gap-8">
            <!-- Filters Sidebar -->
            <div class="lg:w-64 flex-shrink-0">
                <div class="card p-6 sticky top-24">
                    <h3 class="font-semibold text-slate-900 mb-4">Filters</h3>

                    <!-- Skills -->
                    <div>
                        <label
                            class="block text-sm font-medium text-slate-700 mb-2"
                            >Skills</label
                        >
                        <div class="flex flex-wrap gap-2">
                            {#each popularSkills as skill}
                                <button
                                    on:click={() => toggleSkill(skill)}
                                    class="px-3 py-1 text-xs rounded-full transition-colors {selectedSkills.includes(
                                        skill.toLowerCase().replace(/ /g, '-'),
                                    )
                                        ? 'bg-primary-600 text-white'
                                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}"
                                >
                                    {skill}
                                </button>
                            {/each}
                        </div>
                    </div>

                    {#if selectedSkills.length > 0}
                        <button
                            on:click={clearFilters}
                            class="mt-4 text-sm text-primary-600 hover:text-primary-700"
                        >
                            Clear filters
                        </button>
                    {/if}
                </div>
            </div>

            <!-- Freelancers Grid -->
            <div class="flex-1">
                {#if isLoading}
                    <div
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
                    >
                        {#each [1, 2, 3, 4, 5, 6] as _}
                            <div class="card p-6">
                                <div class="flex items-center gap-4 mb-4">
                                    <div
                                        class="skeleton w-14 h-14 rounded-full"
                                    ></div>
                                    <div class="flex-1">
                                        <div
                                            class="skeleton h-5 w-3/4 mb-2"
                                        ></div>
                                        <div class="skeleton h-4 w-1/2"></div>
                                    </div>
                                </div>
                                <div class="skeleton h-4 w-full mb-2"></div>
                                <div class="skeleton h-4 w-2/3"></div>
                            </div>
                        {/each}
                    </div>
                {:else if freelancers.length === 0}
                    <div class="card p-12 text-center">
                        <div class="text-4xl mb-4">👥</div>
                        <h3 class="text-lg font-medium text-slate-900 mb-2">
                            No freelancers found
                        </h3>
                        <p class="text-slate-600">
                            Try adjusting your filters or search terms.
                        </p>
                    </div>
                {:else}
                    <div
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
                    >
                        {#each freelancers as freelancer}
                            <a
                                href="/users/{freelancer.id}"
                                class="card card-hover p-6 block"
                            >
                                <div class="flex items-center gap-4 mb-4">
                                    <div
                                        class="w-14 h-14 bg-primary-100 rounded-full flex items-center justify-center"
                                    >
                                        {#if freelancer.avatar_url}
                                            <img
                                                src={freelancer.avatar_url}
                                                alt={freelancer.name}
                                                class="w-14 h-14 rounded-full object-cover"
                                            />
                                        {:else}
                                            <span
                                                class="text-primary-600 font-bold text-xl"
                                            >
                                                {freelancer.name.charAt(0)}
                                            </span>
                                        {/if}
                                    </div>
                                    <div>
                                        <h2
                                            class="font-semibold text-slate-900"
                                        >
                                            {freelancer.name}
                                        </h2>
                                        {#if freelancer.location}
                                            <p class="text-sm text-slate-500">
                                                📍 {freelancer.location}
                                            </p>
                                        {/if}
                                    </div>
                                </div>

                                {#if freelancer.bio}
                                    <p
                                        class="text-slate-600 text-sm mb-4 line-clamp-2"
                                    >
                                        {freelancer.bio}
                                    </p>
                                {/if}

                                <div
                                    class="flex items-center justify-between text-sm mb-3"
                                >
                                    {#if freelancer.hourly_rate}
                                        <span
                                            class="font-semibold text-slate-900"
                                        >
                                            ${freelancer.hourly_rate}/hr
                                        </span>
                                    {:else}
                                        <span class="text-slate-400">
                                            Rate not set
                                        </span>
                                    {/if}
                                    <span class="text-slate-500">
                                        ⭐ {freelancer.rating_cache?.toFixed(
                                            1,
                                        ) || "New"}
                                    </span>
                                </div>

                                {#if freelancer.skills && freelancer.skills.length > 0}
                                    <div class="flex flex-wrap gap-1">
                                        {#each freelancer.skills.slice(0, 3) as skill}
                                            <span class="badge-gray text-xs"
                                                >{skill}</span
                                            >
                                        {/each}
                                        {#if freelancer.skills.length > 3}
                                            <span class="badge-gray text-xs">
                                                +{freelancer.skills.length - 3}
                                            </span>
                                        {/if}
                                    </div>
                                {/if}
                            </a>
                        {/each}
                    </div>

                    <!-- Pagination -->
                    {#if totalPages > 1}
                        <div class="mt-8 flex justify-center gap-2">
                            <button
                                on:click={prevPage}
                                disabled={currentPage === 1}
                                class="btn-secondary"
                            >
                                Previous
                            </button>
                            <span class="px-4 py-2 text-slate-600">
                                Page {currentPage} of {totalPages}
                            </span>
                            <button
                                on:click={nextPage}
                                disabled={currentPage === totalPages}
                                class="btn-secondary"
                            >
                                Next
                            </button>
                        </div>
                    {/if}
                {/if}
            </div>
        </div>
    </div>
</div>
