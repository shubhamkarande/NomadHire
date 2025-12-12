<script lang="ts">
  import { onMount } from "svelte";
  import { api, type Job } from "$lib/api";

  let jobs: Job[] = [];
  let isLoading = true;
  let searchQuery = "";
  let selectedSkills: string[] = [];
  let budgetType: "all" | "fixed" | "hourly" = "all";
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
    loadJobs();
  });

  async function loadJobs() {
    isLoading = true;
    const params: Record<string, string | string[]> = {
      page: currentPage.toString(),
      per_page: "10",
    };

    if (searchQuery) params.q = searchQuery;
    if (selectedSkills.length > 0) params.skill = selectedSkills;
    if (budgetType !== "all") params.budget_type = budgetType;

    const result = await api.getJobs(params);
    if (result.data) {
      jobs = result.data.jobs;
      totalPages = result.data.meta.total_pages;
    }
    isLoading = false;
  }

  function toggleSkill(skill: string) {
    if (selectedSkills.includes(skill)) {
      selectedSkills = selectedSkills.filter((s) => s !== skill);
    } else {
      selectedSkills = [...selectedSkills, skill];
    }
    currentPage = 1;
    loadJobs();
  }

  function handleSearch() {
    currentPage = 1;
    loadJobs();
  }

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === "Enter") handleSearch();
  }

  function setBudgetType(type: string) {
    budgetType = type as "all" | "fixed" | "hourly";
    loadJobs();
  }

  function clearFilters() {
    selectedSkills = [];
    loadJobs();
  }

  function prevPage() {
    currentPage = Math.max(1, currentPage - 1);
    loadJobs();
  }

  function nextPage() {
    currentPage = Math.min(totalPages, currentPage + 1);
    loadJobs();
  }

  function formatCurrency(amount: number) {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
      maximumFractionDigits: 0,
    }).format(amount);
  }

  function timeAgo(dateString: string) {
    const date = new Date(dateString);
    const now = new Date();
    const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (seconds < 60) return "just now";
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    return `${Math.floor(seconds / 86400)}d ago`;
  }
</script>

<svelte:head>
  <title>Browse Jobs - NomadHire</title>
  <meta
    name="description"
    content="Find freelance jobs and projects. Browse opportunities from clients worldwide."
  />
</svelte:head>

<div class="bg-gradient-to-br from-slate-50 to-primary-50/30 min-h-screen">
  <!-- Header -->
  <div class="bg-white border-b border-slate-100">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 class="text-3xl font-display font-bold text-slate-900 mb-2">
        Browse Jobs
      </h1>
      <p class="text-slate-600">
        Find your next opportunity from {jobs.length}+ open positions
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
            placeholder="Search jobs by title, description, or skills..."
            class="input pl-12"
          />
        </div>
        <button on:click={handleSearch} class="btn-primary"> Search </button>
      </div>
    </div>
  </div>

  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex flex-col lg:flex-row gap-8">
      <!-- Filters Sidebar -->
      <div class="lg:w-64 flex-shrink-0">
        <div class="card p-6 sticky top-24">
          <h3 class="font-semibold text-slate-900 mb-4">Filters</h3>

          <!-- Budget Type -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-slate-700 mb-2"
              >Budget Type</label
            >
            <div class="space-y-2">
              {#each [["all", "All Types"], ["fixed", "Fixed Price"], ["hourly", "Hourly"]] as [value, label]}
                <label class="flex items-center">
                  <input
                    type="radio"
                    name="budgetType"
                    checked={budgetType === value}
                    on:change={() => setBudgetType(value)}
                    class="w-4 h-4 text-primary-600 border-slate-300 focus:ring-primary-500"
                  />
                  <span class="ml-2 text-sm text-slate-600">{label}</span>
                </label>
              {/each}
            </div>
          </div>

          <!-- Skills -->
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2"
              >Skills</label
            >
            <div class="flex flex-wrap gap-2">
              {#each popularSkills as skill}
                <button
                  on:click={() =>
                    toggleSkill(skill.toLowerCase().replace(/ /g, "-"))}
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

      <!-- Jobs List -->
      <div class="flex-1">
        {#if isLoading}
          <div class="space-y-4">
            {#each [1, 2, 3, 4] as _}
              <div class="card p-6">
                <div class="skeleton h-6 w-3/4 mb-3"></div>
                <div class="skeleton h-4 w-full mb-2"></div>
                <div class="skeleton h-4 w-2/3"></div>
              </div>
            {/each}
          </div>
        {:else if jobs.length === 0}
          <div class="card p-12 text-center">
            <div class="text-4xl mb-4">🔍</div>
            <h3 class="text-lg font-medium text-slate-900 mb-2">
              No jobs found
            </h3>
            <p class="text-slate-600">
              Try adjusting your filters or search terms.
            </p>
          </div>
        {:else}
          <div class="space-y-4">
            {#each jobs as job}
              <a href="/jobs/{job.id}" class="card card-hover p-6 block">
                <div class="flex items-start justify-between mb-3">
                  <div class="flex-1">
                    <div class="flex items-center gap-3 mb-2">
                      <h2
                        class="text-lg font-semibold text-slate-900 hover:text-primary-600 transition-colors"
                      >
                        {job.title}
                      </h2>
                      <span
                        class="badge-{job.budget_type === 'fixed'
                          ? 'primary'
                          : 'success'}"
                      >
                        {job.budget_type}
                      </span>
                    </div>
                    <div class="flex items-center gap-4 text-sm text-slate-500">
                      <span class="flex items-center gap-1">
                        <svg
                          class="w-4 h-4"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                          />
                        </svg>
                        {job.client.name}
                      </span>
                      <span>{timeAgo(job.created_at)}</span>
                    </div>
                  </div>
                  <div class="text-right">
                    <div class="text-lg font-semibold text-slate-900">
                      {formatCurrency(job.budget_min)}{job.budget_max
                        ? ` - ${formatCurrency(job.budget_max)}`
                        : ""}
                    </div>
                    <div class="text-sm text-slate-500">
                      {job.bids_count} proposals
                    </div>
                  </div>
                </div>

                <p class="text-slate-600 mb-4 line-clamp-2">
                  {job.description}
                </p>

                <div class="flex flex-wrap gap-2">
                  {#each job.skills.slice(0, 5) as skill}
                    <span class="badge-gray">{skill}</span>
                  {/each}
                  {#if job.skills.length > 5}
                    <span class="badge-gray">+{job.skills.length - 5} more</span
                    >
                  {/if}
                </div>
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
