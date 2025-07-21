<script lang="ts">
  import { onMount } from "svelte";
  import { Search, Filter, MapPin, DollarSign, Clock } from "lucide-svelte";
  import ProjectCard from "../lib/components/ProjectCard.svelte";
  import Button from "../lib/components/Button.svelte";
  import Card from "../lib/components/Card.svelte";
  import { fadeInUp, staggerFadeIn } from "../lib/animations";
  import { supabase } from "../lib/supabase";
  import type { Project } from "../lib/supabase";

  let searchQuery = "";
  let selectedSkills: string[] = [];
  let budgetRange = "all";
  let projectType = "all";
  let projects: (Project & { client?: any })[] = [];
  let isLoading = true;
  let showFilters = false;

  let pageElement: HTMLElement;

  const skillOptions = [
    "JavaScript",
    "Python",
    "React",
    "Node.js",
    "Vue.js",
    "PHP",
    "Java",
    "UI/UX Design",
    "Graphic Design",
    "WordPress",
    "Mobile App",
    "Data Science",
  ];

  async function loadProjects() {
    isLoading = true;
    try {
      let query = supabase
        .from("projects")
        .select(
          `
          *,
          client:profiles!client_id(first_name, last_name, location)
        `,
        )
        .eq("status", "open");

      if (searchQuery.trim()) {
        query = query.or(
          `title.ilike.%${searchQuery}%,description.ilike.%${searchQuery}%`,
        );
      }

      if (selectedSkills.length > 0) {
        query = query.overlaps("skills_required", selectedSkills);
      }

      if (budgetRange !== "all") {
        const [min, max] = budgetRange.split("-").map(Number);
        if (max) {
          query = query.gte("budget", min).lte("budget", max);
        } else {
          query = query.gte("budget", min);
        }
      }

      if (projectType !== "all") {
        query = query.eq("budget_type", projectType);
      }

      const { data, error } = await query.order("created_at", {
        ascending: false,
      });

      if (error) throw error;
      projects = data || [];
    } catch (error) {
      console.error("Error loading projects:", error);
    } finally {
      isLoading = false;
    }
  }

  function toggleSkill(skill: string) {
    if (selectedSkills.includes(skill)) {
      selectedSkills = selectedSkills.filter((s) => s !== skill);
    } else {
      selectedSkills = [...selectedSkills, skill];
    }
    loadProjects();
  }

  function clearFilters() {
    searchQuery = "";
    selectedSkills = [];
    budgetRange = "all";
    projectType = "all";
    loadProjects();
  }

  onMount(() => {
    if (pageElement) {
      fadeInUp(pageElement);
    }
    loadProjects();
  });

  let searchTimeout: number;

  $: if (
    searchQuery !== undefined ||
    budgetRange !== undefined ||
    projectType !== undefined
  ) {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(loadProjects, 300);
  }
</script>

<div bind:this={pageElement} class="min-h-screen bg-gray-50 dark:bg-gray-900">
  <!-- Header -->
  <div
    class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700"
  >
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">
        Browse Projects
      </h1>
      <p class="text-gray-600 dark:text-gray-400 mb-6">
        Discover exciting opportunities from clients around the world
      </p>

      <!-- Search and Filter Bar -->
      <div class="flex flex-col lg:flex-row gap-4">
        <!-- Search -->
        <div class="flex-1 relative">
          <Search
            size={20}
            class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
          />
          <input
            bind:value={searchQuery}
            type="text"
            placeholder="Search projects by title or description..."
            class="w-full pl-10 pr-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          />
        </div>

        <!-- Filter Toggle -->
        <Button variant="outline" on:click={() => (showFilters = !showFilters)}>
          <Filter size={20} class="mr-2" />
          Filters
        </Button>
      </div>

      <!-- Filters Panel -->
      {#if showFilters}
        <Card padding="md" class="mt-6">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Budget Range -->
            <div>
              <label
                class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2"
              >
                Budget Range
              </label>
              <select
                bind:value={budgetRange}
                class="w-full rounded-md border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="all">All Budgets</option>
                <option value="0-500">$0 - $500</option>
                <option value="500-1000">$500 - $1,000</option>
                <option value="1000-5000">$1,000 - $5,000</option>
                <option value="5000-10000">$5,000 - $10,000</option>
                <option value="10000">$10,000+</option>
              </select>
            </div>

            <!-- Project Type -->
            <div>
              <label
                class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2"
              >
                Project Type
              </label>
              <select
                bind:value={projectType}
                class="w-full rounded-md border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="all">All Types</option>
                <option value="fixed">Fixed Price</option>
                <option value="hourly">Hourly Rate</option>
              </select>
            </div>

            <!-- Clear Filters -->
            <div class="flex items-end">
              <Button variant="ghost" on:click={clearFilters} class="w-full">
                Clear Filters
              </Button>
            </div>
          </div>

          <!-- Skills Filter -->
          <div class="mt-6">
            <label
              class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3"
            >
              Skills
            </label>
            <div class="flex flex-wrap gap-2">
              {#each skillOptions as skill}
                <button
                  on:click={() => toggleSkill(skill)}
                  class="px-3 py-1 text-sm rounded-full border transition-colors {selectedSkills.includes(
                    skill,
                  )
                    ? 'bg-primary-600 text-white border-primary-600'
                    : 'bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 border-gray-300 dark:border-gray-600 hover:border-primary-500'}"
                >
                  {skill}
                </button>
              {/each}
            </div>
          </div>
        </Card>
      {/if}
    </div>
  </div>

  <!-- Projects Grid -->
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    {#if isLoading}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {#each Array(6) as _}
          <div
            class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 animate-pulse"
          >
            <div
              class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4 mb-4"
            ></div>
            <div
              class="h-3 bg-gray-200 dark:bg-gray-700 rounded w-full mb-2"
            ></div>
            <div
              class="h-3 bg-gray-200 dark:bg-gray-700 rounded w-2/3 mb-4"
            ></div>
            <div class="flex space-x-2 mb-4">
              <div class="h-6 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
              <div class="h-6 bg-gray-200 dark:bg-gray-700 rounded w-20"></div>
            </div>
            <div class="h-8 bg-gray-200 dark:bg-gray-700 rounded w-24"></div>
          </div>
        {/each}
      </div>
    {:else if projects.length === 0}
      <Card padding="lg" class="text-center">
        <div class="py-12">
          <Search size={48} class="mx-auto text-gray-400 mb-4" />
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
            No projects found
          </h3>
          <p class="text-gray-600 dark:text-gray-400 mb-6">
            Try adjusting your search criteria or clearing filters
          </p>
          <Button variant="outline" on:click={clearFilters}>
            Clear All Filters
          </Button>
        </div>
      </Card>
    {:else}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {#each projects as project (project.id)}
          <ProjectCard {project} />
        {/each}
      </div>

      <!-- Load More -->
      {#if projects.length >= 10}
        <div class="text-center mt-12">
          <Button variant="outline" size="lg">Load More Projects</Button>
        </div>
      {/if}
    {/if}
  </div>
</div>
