<script lang="ts">
    import { onMount } from "svelte";
    import { goto } from "$app/navigation";
    import {
        auth,
        user,
        isAuthenticated,
        isClient,
        isFreelancer,
    } from "$lib/stores/auth";
    import { api, type Job, type Contract, type Bid } from "$lib/api";

    let isLoading = true;
    let contracts: Contract[] = [];
    let recentJobs: Job[] = [];
    let myBids: Bid[] = [];

    onMount(async () => {
        if (!$isAuthenticated) {
            goto("/auth/login");
            return;
        }

        // Load dashboard data
        const [contractsRes, jobsRes] = await Promise.all([
            api.getContracts(),
            api.getJobs({ per_page: "5" }),
        ]);

        if (contractsRes.data) {
            contracts = contractsRes.data.contracts;
        }

        if (jobsRes.data) {
            recentJobs = jobsRes.data.jobs;
        }

        isLoading = false;
    });

    function formatCurrency(amount: number) {
        return new Intl.NumberFormat("en-US", {
            style: "currency",
            currency: "USD",
        }).format(amount);
    }

    function getStatusColor(status: string) {
        const colors: Record<string, string> = {
            open: "badge-primary",
            active: "badge-success",
            completed: "badge-gray",
            pending: "badge-warning",
            paid: "badge-success",
            delivered: "badge-primary",
            released: "badge-success",
        };
        return colors[status] || "badge-gray";
    }
</script>

<svelte:head>
    <title>Dashboard - NomadHire</title>
</svelte:head>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Header -->
    <div class="mb-8">
        <h1 class="text-2xl font-display font-bold text-slate-900">
            Welcome back, {$user?.name || "User"}! 👋
        </h1>
        <p class="text-slate-600 mt-1">
            {#if $isClient}
                Manage your projects and find talented freelancers.
            {:else if $isFreelancer}
                Find new opportunities and manage your ongoing work.
            {:else}
                Here's your dashboard overview.
            {/if}
        </p>
    </div>

    {#if isLoading}
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            {#each [1, 2, 3] as _}
                <div class="card p-6">
                    <div class="skeleton h-4 w-24 mb-2"></div>
                    <div class="skeleton h-8 w-16"></div>
                </div>
            {/each}
        </div>
    {:else}
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="card p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm font-medium text-slate-600">
                            Active Contracts
                        </p>
                        <p class="text-2xl font-bold text-slate-900 mt-1">
                            {contracts.filter((c) => c.status === "active")
                                .length}
                        </p>
                    </div>
                    <div
                        class="w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center"
                    >
                        <svg
                            class="w-6 h-6 text-primary-600"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                            />
                        </svg>
                    </div>
                </div>
            </div>

            <div class="card p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm font-medium text-slate-600">
                            {$isClient ? "Total Spent" : "Total Earned"}
                        </p>
                        <p class="text-2xl font-bold text-slate-900 mt-1">
                            {formatCurrency(
                                contracts.reduce(
                                    (sum, c) => sum + c.total_released,
                                    0,
                                ),
                            )}
                        </p>
                    </div>
                    <div
                        class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center"
                    >
                        <svg
                            class="w-6 h-6 text-green-600"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                            />
                        </svg>
                    </div>
                </div>
            </div>

            <div class="card p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm font-medium text-slate-600">
                            Completed Projects
                        </p>
                        <p class="text-2xl font-bold text-slate-900 mt-1">
                            {contracts.filter((c) => c.status === "completed")
                                .length}
                        </p>
                    </div>
                    <div
                        class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center"
                    >
                        <svg
                            class="w-6 h-6 text-purple-600"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                            />
                        </svg>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="mb-8">
            <h2 class="text-lg font-semibold text-slate-900 mb-4">
                Quick Actions
            </h2>
            <div class="flex flex-wrap gap-4">
                {#if $isClient}
                    <a href="/jobs/new" class="btn-primary">
                        <svg
                            class="w-5 h-5 mr-2"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M12 4v16m8-8H4"
                            />
                        </svg>
                        Post a New Job
                    </a>
                    <a href="/freelancers" class="btn-secondary">
                        Find Talent
                    </a>
                {:else}
                    <a href="/jobs" class="btn-primary"> Browse Jobs </a>
                    <a href="/profile" class="btn-secondary">
                        Update Profile
                    </a>
                {/if}
                <a href="/chat" class="btn-secondary"> Messages </a>
            </div>
        </div>

        <!-- Active Contracts -->
        {#if contracts.length > 0}
            <div class="mb-8">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="text-lg font-semibold text-slate-900">
                        Your Contracts
                    </h2>
                    <a
                        href="/contracts"
                        class="text-primary-600 hover:text-primary-700 text-sm font-medium"
                    >
                        View All →
                    </a>
                </div>
                <div class="grid gap-4">
                    {#each contracts.slice(0, 3) as contract}
                        <a
                            href="/contracts/{contract.id}"
                            class="card card-hover p-4 flex items-center justify-between"
                        >
                            <div class="flex items-center gap-4">
                                <div
                                    class="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center"
                                >
                                    <span class="text-primary-600 font-medium">
                                        {$isClient
                                            ? contract.freelancer.name.charAt(0)
                                            : contract.client.name.charAt(0)}
                                    </span>
                                </div>
                                <div>
                                    <h3 class="font-medium text-slate-900">
                                        {contract.job.title}
                                    </h3>
                                    <p class="text-sm text-slate-500">
                                        with {$isClient
                                            ? contract.freelancer.name
                                            : contract.client.name}
                                    </p>
                                </div>
                            </div>
                            <div class="text-right">
                                <span class={getStatusColor(contract.status)}
                                    >{contract.status}</span
                                >
                                <p class="text-sm text-slate-500 mt-1">
                                    {formatCurrency(contract.total_amount)}
                                </p>
                            </div>
                        </a>
                    {/each}
                </div>
            </div>
        {/if}

        <!-- Recent Jobs (for freelancers) -->
        {#if $isFreelancer && recentJobs.length > 0}
            <div>
                <div class="flex items-center justify-between mb-4">
                    <h2 class="text-lg font-semibold text-slate-900">
                        Latest Jobs
                    </h2>
                    <a
                        href="/jobs"
                        class="text-primary-600 hover:text-primary-700 text-sm font-medium"
                    >
                        View All →
                    </a>
                </div>
                <div class="grid gap-4 md:grid-cols-2">
                    {#each recentJobs.slice(0, 4) as job}
                        <a href="/jobs/{job.id}" class="card card-hover p-4">
                            <div class="flex items-start justify-between mb-2">
                                <h3
                                    class="font-medium text-slate-900 line-clamp-1"
                                >
                                    {job.title}
                                </h3>
                                <span class="badge-primary ml-2 flex-shrink-0"
                                    >{job.budget_type}</span
                                >
                            </div>
                            <p class="text-sm text-slate-500 line-clamp-2 mb-3">
                                {job.description}
                            </p>
                            <div
                                class="flex items-center justify-between text-sm"
                            >
                                <span class="text-slate-600">
                                    {formatCurrency(
                                        job.budget_min,
                                    )}{job.budget_max
                                        ? ` - ${formatCurrency(job.budget_max)}`
                                        : ""}
                                </span>
                                <span class="text-slate-400"
                                    >{job.bids_count} bids</span
                                >
                            </div>
                        </a>
                    {/each}
                </div>
            </div>
        {/if}
    {/if}
</div>
