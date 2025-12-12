<script lang="ts">
    import { onMount } from "svelte";
    import { page } from "$app/stores";
    import { goto } from "$app/navigation";
    import { api, type Job, type Bid } from "$lib/api";
    import {
        user,
        isAuthenticated,
        isFreelancer,
        isClient,
    } from "$lib/stores/auth";

    let job: Job | null = null;
    let isLoading = true;
    let error = "";

    // Bid form state
    let showBidModal = false;
    let bidAmount = 0;
    let coverLetter = "";
    let estimatedDays = 14;
    let bidError = "";
    let bidLoading = false;

    onMount(() => {
        loadJob();
    });

    async function loadJob() {
        const id = Number($page.params.id);
        if (isNaN(id)) {
            error = "Invalid job ID";
            isLoading = false;
            return;
        }

        const result = await api.getJob(id);
        if (result.data) {
            job = result.data.job;
            bidAmount = job.budget_min;
        } else {
            error = result.error || "Job not found";
        }
        isLoading = false;
    }

    async function submitBid() {
        if (!job) return;

        bidError = "";
        bidLoading = true;

        const result = await api.createBid(job.id, {
            amount: bidAmount,
            cover_letter: coverLetter,
            estimated_days: estimatedDays,
        });

        if (result.data) {
            showBidModal = false;
            // Reload job to show new bid
            await loadJob();
        } else {
            bidError = result.error || "Failed to submit bid";
        }

        bidLoading = false;
    }

    async function acceptBid(bidId: number) {
        const result = await api.acceptBid(bidId);
        if (result.data) {
            goto(`/contracts/${result.data.contract.id}`);
        }
    }

    function handleBidSubmit(e: Event) {
        e.preventDefault();
        submitBid();
    }

    function openBidModal() {
        showBidModal = true;
    }

    function closeBidModal() {
        showBidModal = false;
    }

    function stopPropagation(e: Event) {
        e.stopPropagation();
    }

    function formatCurrency(amount: number) {
        return new Intl.NumberFormat("en-US", {
            style: "currency",
            currency: "USD",
        }).format(amount);
    }

    function formatDate(dateString: string) {
        return new Date(dateString).toLocaleDateString("en-US", {
            year: "numeric",
            month: "long",
            day: "numeric",
        });
    }
</script>

<svelte:head>
    <title>{job?.title || "Job Details"} - NomadHire</title>
</svelte:head>

{#if isLoading}
    <div class="max-w-4xl mx-auto px-4 py-12">
        <div class="skeleton h-8 w-2/3 mb-4"></div>
        <div class="skeleton h-4 w-full mb-2"></div>
        <div class="skeleton h-4 w-3/4"></div>
    </div>
{:else if error}
    <div class="max-w-4xl mx-auto px-4 py-12 text-center">
        <div class="text-4xl mb-4">😕</div>
        <h1 class="text-2xl font-bold text-slate-900 mb-2">Job Not Found</h1>
        <p class="text-slate-600 mb-4">{error}</p>
        <a href="/jobs" class="btn-primary">Browse Jobs</a>
    </div>
{:else if job}
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="grid lg:grid-cols-3 gap-8">
            <!-- Main Content -->
            <div class="lg:col-span-2">
                <div class="card p-6 mb-6">
                    <!-- Header -->
                    <div class="flex items-start justify-between mb-6">
                        <div>
                            <div class="flex items-center gap-3 mb-2">
                                <span
                                    class="badge-{job.status === 'open'
                                        ? 'success'
                                        : 'gray'}">{job.status}</span
                                >
                                <span
                                    class="badge-{job.budget_type === 'fixed'
                                        ? 'primary'
                                        : 'warning'}"
                                    >{job.budget_type} price</span
                                >
                            </div>
                            <h1
                                class="text-2xl font-display font-bold text-slate-900"
                            >
                                {job.title}
                            </h1>
                        </div>
                    </div>

                    <!-- Description -->
                    <div class="prose prose-slate max-w-none mb-6">
                        <h3 class="text-lg font-semibold">Description</h3>
                        <p class="whitespace-pre-wrap text-slate-700">
                            {job.description}
                        </p>
                    </div>

                    <!-- Skills -->
                    <div class="mb-6">
                        <h3 class="text-lg font-semibold text-slate-900 mb-3">
                            Skills Required
                        </h3>
                        <div class="flex flex-wrap gap-2">
                            {#each job.skills as skill}
                                <span class="badge-primary">{skill}</span>
                            {/each}
                        </div>
                    </div>

                    <!-- Details -->
                    <div
                        class="grid grid-cols-2 md:grid-cols-4 gap-4 p-4 bg-slate-50 rounded-lg"
                    >
                        <div>
                            <p class="text-sm text-slate-500">Budget</p>
                            <p class="font-semibold text-slate-900">
                                {formatCurrency(job.budget_min)}{job.budget_max
                                    ? ` - ${formatCurrency(job.budget_max)}`
                                    : ""}
                            </p>
                        </div>
                        <div>
                            <p class="text-sm text-slate-500">Deadline</p>
                            <p class="font-semibold text-slate-900">
                                {formatDate(job.deadline)}
                            </p>
                        </div>
                        <div>
                            <p class="text-sm text-slate-500">Proposals</p>
                            <p class="font-semibold text-slate-900">
                                {job.bids_count}
                            </p>
                        </div>
                        <div>
                            <p class="text-sm text-slate-500">Posted</p>
                            <p class="font-semibold text-slate-900">
                                {formatDate(job.created_at)}
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Bids (for job owner) -->
                {#if $isClient && $user?.id === job.client.id && job.bids && job.bids.length > 0}
                    <div class="card p-6">
                        <h2 class="text-lg font-semibold text-slate-900 mb-4">
                            Proposals ({job.bids.length})
                        </h2>
                        <div class="space-y-4">
                            {#each job.bids as bid}
                                <div
                                    class="border border-slate-200 rounded-lg p-4"
                                >
                                    <div
                                        class="flex items-start justify-between mb-3"
                                    >
                                        <div class="flex items-center gap-3">
                                            <div
                                                class="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center"
                                            >
                                                <span
                                                    class="text-primary-600 font-medium"
                                                    >{bid.freelancer.name.charAt(
                                                        0,
                                                    )}</span
                                                >
                                            </div>
                                            <div>
                                                <a
                                                    href="/users/{bid.freelancer
                                                        .id}"
                                                    class="font-medium text-slate-900 hover:text-primary-600"
                                                >
                                                    {bid.freelancer.name}
                                                </a>
                                                <div
                                                    class="flex items-center gap-1 text-sm text-slate-500"
                                                >
                                                    <span
                                                        >⭐ {bid.freelancer.rating_cache?.toFixed(
                                                            1,
                                                        ) || "New"}</span
                                                    >
                                                </div>
                                            </div>
                                        </div>
                                        <div class="text-right">
                                            <p
                                                class="font-semibold text-slate-900"
                                            >
                                                {formatCurrency(bid.amount)}
                                            </p>
                                            <p class="text-sm text-slate-500">
                                                {bid.estimated_days} days
                                            </p>
                                        </div>
                                    </div>
                                    <p class="text-slate-600 text-sm mb-3">
                                        {bid.cover_letter}
                                    </p>
                                    {#if bid.status === "pending" && job.status === "open"}
                                        <div class="flex gap-2">
                                            <button
                                                on:click={() =>
                                                    acceptBid(bid.id)}
                                                class="btn-primary btn-sm"
                                            >
                                                Accept Proposal
                                            </button>
                                            <button
                                                class="btn-ghost btn-sm text-error-600"
                                            >
                                                Decline
                                            </button>
                                        </div>
                                    {:else}
                                        <span
                                            class="badge-{bid.status ===
                                            'accepted'
                                                ? 'success'
                                                : 'gray'}">{bid.status}</span
                                        >
                                    {/if}
                                </div>
                            {/each}
                        </div>
                    </div>
                {/if}
            </div>

            <!-- Sidebar -->
            <div class="lg:col-span-1">
                <!-- Apply CTA -->
                {#if job.status === "open"}
                    <div class="card p-6 mb-6">
                        {#if $isFreelancer}
                            <button
                                on:click={openBidModal}
                                class="btn-primary w-full mb-4"
                            >
                                Submit Proposal
                            </button>
                            <p class="text-sm text-slate-500 text-center">
                                Send a proposal and get hired
                            </p>
                        {:else if !$isAuthenticated}
                            <a
                                href="/auth/register?role=freelancer"
                                class="btn-primary w-full block text-center mb-4"
                            >
                                Sign Up to Apply
                            </a>
                            <p class="text-sm text-slate-500 text-center">
                                Create a freelancer account to apply
                            </p>
                        {:else}
                            <p class="text-sm text-slate-500 text-center">
                                Only freelancers can apply to jobs
                            </p>
                        {/if}
                    </div>
                {/if}

                <!-- Client Info -->
                <div class="card p-6">
                    <h3 class="font-semibold text-slate-900 mb-4">
                        About the Client
                    </h3>
                    <div class="flex items-center gap-3 mb-4">
                        <div
                            class="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center"
                        >
                            <span class="text-primary-600 font-bold text-lg"
                                >{job.client.name.charAt(0)}</span
                            >
                        </div>
                        <div>
                            <a
                                href="/users/{job.client.id}"
                                class="font-medium text-slate-900 hover:text-primary-600"
                            >
                                {job.client.name}
                            </a>
                            <p class="text-sm text-slate-500">
                                Member since 2024
                            </p>
                        </div>
                    </div>
                    <a
                        href="/chat?user={job.client.id}"
                        class="btn-outline w-full"
                    >
                        Contact Client
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Bid Modal -->
    {#if showBidModal}
        <div
            class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
            on:click={closeBidModal}
            on:keydown={(e) => e.key === "Escape" && closeBidModal()}
            role="dialog"
            tabindex="-1"
        >
            <div
                class="card w-full max-w-lg p-6 animate-scale-in"
                on:click={stopPropagation}
                on:keydown={stopPropagation}
                role="document"
            >
                <h2 class="text-xl font-display font-bold text-slate-900 mb-6">
                    Submit Your Proposal
                </h2>

                {#if bidError}
                    <div
                        class="mb-4 p-3 bg-red-50 border border-red-100 rounded-lg text-red-600 text-sm"
                    >
                        {bidError}
                    </div>
                {/if}

                <form on:submit|preventDefault={handleBidSubmit}>
                    <div class="mb-4">
                        <label
                            class="block text-sm font-medium text-slate-700 mb-1"
                            >Your Bid Amount</label
                        >
                        <div class="relative">
                            <span
                                class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
                                >$</span
                            >
                            <input
                                type="number"
                                bind:value={bidAmount}
                                min="1"
                                required
                                class="input pl-8"
                            />
                        </div>
                        <p class="text-xs text-slate-500 mt-1">
                            Client's budget: {formatCurrency(
                                job.budget_min,
                            )}{job.budget_max
                                ? ` - ${formatCurrency(job.budget_max)}`
                                : ""}
                        </p>
                    </div>

                    <div class="mb-4">
                        <label
                            class="block text-sm font-medium text-slate-700 mb-1"
                            >Estimated Delivery (days)</label
                        >
                        <input
                            type="number"
                            bind:value={estimatedDays}
                            min="1"
                            max="365"
                            required
                            class="input"
                        />
                    </div>

                    <div class="mb-6">
                        <label
                            class="block text-sm font-medium text-slate-700 mb-1"
                            >Cover Letter</label
                        >
                        <textarea
                            bind:value={coverLetter}
                            required
                            minlength="50"
                            rows="5"
                            class="input"
                            placeholder="Explain why you're the best fit for this job..."
                        ></textarea>
                        <p class="text-xs text-slate-500 mt-1">
                            Minimum 50 characters
                        </p>
                    </div>

                    <div class="flex gap-3">
                        <button
                            type="button"
                            on:click={closeBidModal}
                            class="btn-secondary flex-1"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={bidLoading}
                            class="btn-primary flex-1"
                        >
                            {#if bidLoading}
                                Submitting...
                            {:else}
                                Submit Proposal
                            {/if}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    {/if}
{/if}
