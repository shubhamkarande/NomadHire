<script lang="ts">
  import { onMount } from "svelte";
  import { goto } from "$app/navigation";
  import { api, type Contract } from "$lib/api";
  import { user, isAuthenticated, isClient } from "$lib/stores/auth";

  let contracts: Contract[] = [];
  let isLoading = true;
  let filter: "all" | "active" | "completed" = "all";

  onMount(async () => {
    if (!$isAuthenticated) {
      goto("/auth/login");
      return;
    }

    const result = await api.getContracts();
    if (result.data) {
      contracts = result.data.contracts;
    }
    isLoading = false;
  });

  $: filteredContracts =
    filter === "all" ? contracts : contracts.filter((c) => c.status === filter);

  function formatCurrency(amount: number) {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
    }).format(amount);
  }

  function getStatusColor(status: string) {
    const colors: Record<string, string> = {
      active: "badge-success",
      completed: "badge-primary",
      cancelled: "badge-error",
      disputed: "badge-warning",
    };
    return colors[status] || "badge-gray";
  }

  function setFilter(value: string) {
    filter = value as "all" | "active" | "completed";
  }
</script>

<svelte:head>
  <title>My Contracts - NomadHire</title>
</svelte:head>

<div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
  <div class="flex items-center justify-between mb-8">
    <div>
      <h1 class="text-2xl font-display font-bold text-slate-900">
        My Contracts
      </h1>
      <p class="text-slate-600 mt-1">
        Manage your active and completed projects
      </p>
    </div>
  </div>

  <!-- Filters -->
  <div class="flex gap-2 mb-6">
    {#each [["all", "All"], ["active", "Active"], ["completed", "Completed"]] as [value, label]}
      <button
        on:click={() => setFilter(value)}
        class="px-4 py-2 rounded-lg text-sm font-medium transition-colors {filter ===
        value
          ? 'bg-primary-600 text-white'
          : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-200'}"
      >
        {label}
      </button>
    {/each}
  </div>

  {#if isLoading}
    <div class="space-y-4">
      {#each [1, 2, 3] as _}
        <div class="card p-6">
          <div class="skeleton h-6 w-2/3 mb-3"></div>
          <div class="skeleton h-4 w-1/2"></div>
        </div>
      {/each}
    </div>
  {:else if filteredContracts.length === 0}
    <div class="card p-12 text-center">
      <div class="text-4xl mb-4">📋</div>
      <h3 class="text-lg font-medium text-slate-900 mb-2">
        No contracts found
      </h3>
      <p class="text-slate-600 mb-4">
        {#if $isClient}
          Post a job and hire a freelancer to get started
        {:else}
          Submit proposals to jobs to start working
        {/if}
      </p>
      <a href="/jobs" class="btn-primary">Browse Jobs</a>
    </div>
  {:else}
    <div class="space-y-4">
      {#each filteredContracts as contract}
        <a href="/contracts/{contract.id}" class="card card-hover p-6 block">
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-2">
                <h2 class="text-lg font-semibold text-slate-900">
                  {contract.job.title}
                </h2>
                <span class={getStatusColor(contract.status)}
                  >{contract.status}</span
                >
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
                  {$isClient ? contract.freelancer.name : contract.client.name}
                </span>
                <span
                  >Started {new Date(
                    contract.created_at,
                  ).toLocaleDateString()}</span
                >
              </div>
            </div>
            <div class="text-right">
              <p class="text-lg font-semibold text-slate-900">
                {formatCurrency(contract.total_amount)}
              </p>
              <p class="text-sm text-slate-500">
                {formatCurrency(contract.total_released)} released
              </p>
            </div>
          </div>

          <!-- Progress Bar -->
          {#if contract.status === "active" && contract.milestones}
            <div class="mt-4">
              <div class="flex justify-between text-xs text-slate-500 mb-1">
                <span>Progress</span>
                <span
                  >{Math.round(
                    (contract.total_released / contract.total_amount) * 100,
                  )}%</span
                >
              </div>
              <div class="h-2 bg-slate-100 rounded-full overflow-hidden">
                <div
                  class="h-full bg-primary-600 rounded-full transition-all"
                  style="width: {(contract.total_released /
                    contract.total_amount) *
                    100}%"
                ></div>
              </div>
            </div>
          {/if}
        </a>
      {/each}
    </div>
  {/if}
</div>
