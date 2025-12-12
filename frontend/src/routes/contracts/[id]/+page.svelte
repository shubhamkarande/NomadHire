<script lang="ts">
    import { onMount, onDestroy } from "svelte";
    import { page } from "$app/stores";
    import { goto } from "$app/navigation";
    import { api, type Contract, type Milestone } from "$lib/api";
    import { user, isAuthenticated, isClient } from "$lib/stores/auth";
    import {
        loadStripe,
        type Stripe,
        type StripeElements,
    } from "@stripe/stripe-js";

    let contract: Contract | null = null;
    let isLoading = true;
    let error = "";

    // Payment modal state
    let showPaymentModal = false;
    let selectedMilestone: Milestone | null = null;
    let paymentLoading = false;
    let paymentError = "";
    let paymentSuccess = false;

    // Stripe state
    let stripe: Stripe | null = null;
    let elements: StripeElements | null = null;
    let cardElement: any = null;

    // Create milestone state
    let showCreateModal = false;
    let newMilestone = {
        title: "",
        description: "",
        amount: 0,
        due_date: "",
    };
    let createLoading = false;

    onMount(async () => {
        loadContract();
        // Load Stripe
        const stripeKey = import.meta.env.VITE_STRIPE_KEY;
        if (stripeKey) {
            stripe = await loadStripe(stripeKey);
        }
    });

    async function loadContract() {
        const id = Number($page.params.id);
        if (isNaN(id)) {
            error = "Invalid contract ID";
            isLoading = false;
            return;
        }

        const result = await api.getContract(id);
        if (result.data) {
            contract = result.data.contract;
        } else {
            error = result.error || "Contract not found";
        }
        isLoading = false;
    }

    async function openPaymentModal(milestone: Milestone) {
        selectedMilestone = milestone;
        paymentError = "";
        paymentSuccess = false;
        showPaymentModal = true;

        // Initialize Stripe Elements
        if (stripe) {
            elements = stripe.elements();

            // Wait for modal to render
            await new Promise((resolve) => setTimeout(resolve, 100));

            const cardContainer = document.getElementById("card-element");
            if (cardContainer && elements) {
                cardElement = elements.create("card", {
                    style: {
                        base: {
                            fontSize: "16px",
                            color: "#1e293b",
                            fontFamily: "Inter, system-ui, sans-serif",
                            "::placeholder": { color: "#94a3b8" },
                        },
                        invalid: { color: "#ef4444" },
                    },
                });
                cardElement.mount("#card-element");
            }
        }
    }

    function closePaymentModal() {
        showPaymentModal = false;
        selectedMilestone = null;
        if (cardElement) {
            cardElement.destroy();
            cardElement = null;
        }
    }

    async function processPayment() {
        if (!selectedMilestone || !stripe || !cardElement) return;

        paymentLoading = true;
        paymentError = "";

        try {
            // Get payment intent from backend
            const result = await api.payMilestone(
                selectedMilestone.id,
                "stripe",
            );

            if (!result.data?.client_secret) {
                throw new Error("Failed to create payment");
            }

            // Confirm payment with Stripe
            const { error: stripeError, paymentIntent } =
                await stripe.confirmCardPayment(result.data.client_secret, {
                    payment_method: { card: cardElement },
                });

            if (stripeError) {
                throw new Error(stripeError.message);
            }

            if (paymentIntent?.status === "succeeded") {
                paymentSuccess = true;
                // Reload contract to see updated milestone
                setTimeout(async () => {
                    await loadContract();
                    closePaymentModal();
                }, 2000);
            }
        } catch (e: any) {
            paymentError = e.message || "Payment failed";
        }

        paymentLoading = false;
    }

    async function markDelivered(milestone: Milestone) {
        const result = await api.completeMilestone(milestone.id);
        if (result.data) {
            await loadContract();
        }
    }

    async function releaseFunds(milestone: Milestone) {
        if (
            !confirm(
                "Are you sure you want to release the funds? This action cannot be undone.",
            )
        )
            return;

        const result = await api.releaseMilestone(milestone.id);
        if (result.data) {
            await loadContract();
        }
    }

    async function createMilestoneHandler() {
        if (!contract) return;

        createLoading = true;
        const result = await api.createMilestone(contract.id, newMilestone);

        if (result.data) {
            showCreateModal = false;
            newMilestone = {
                title: "",
                description: "",
                amount: 0,
                due_date: "",
            };
            await loadContract();
        }

        createLoading = false;
    }

    function openCreateModal() {
        showCreateModal = true;
    }

    function closeCreateModal() {
        showCreateModal = false;
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
            month: "short",
            day: "numeric",
        });
    }

    function getStatusColor(status: string) {
        const colors: Record<string, string> = {
            pending: "badge-warning",
            paid: "badge-primary",
            delivered: "badge-success",
            released: "badge-gray",
            failed: "badge-error",
        };
        return colors[status] || "badge-gray";
    }

    function getMilestoneActions(milestone: Milestone) {
        const isContractClient = $user?.id === contract?.client.id;
        const isContractFreelancer = $user?.id === contract?.freelancer.id;

        return {
            canPay: isContractClient && milestone.status === "pending",
            canDeliver: isContractFreelancer && milestone.status === "paid",
            canRelease:
                isContractClient &&
                (milestone.status === "paid" ||
                    milestone.status === "delivered"),
        };
    }
</script>

<svelte:head>
    <title>{contract?.job.title || "Contract"} - NomadHire</title>
</svelte:head>

{#if isLoading}
    <div class="max-w-4xl mx-auto px-4 py-12">
        <div class="skeleton h-8 w-2/3 mb-4"></div>
        <div class="skeleton h-4 w-full mb-2"></div>
        <div class="skeleton h-4 w-3/4"></div>
    </div>
{:else if error}
    <div class="max-w-4xl mx-auto px-4 py-12 text-center">
        <div class="text-4xl mb-4">📋</div>
        <h1 class="text-2xl font-bold text-slate-900 mb-2">
            Contract Not Found
        </h1>
        <p class="text-slate-600 mb-4">{error}</p>
        <a href="/contracts" class="btn-primary">View Contracts</a>
    </div>
{:else if contract}
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="mb-8">
            <div class="flex items-center gap-3 mb-2">
                <a
                    href="/contracts"
                    class="text-slate-500 hover:text-primary-600"
                >
                    ← Back to Contracts
                </a>
            </div>
            <div class="flex items-start justify-between">
                <div>
                    <h1 class="text-2xl font-display font-bold text-slate-900">
                        {contract.job.title}
                    </h1>
                    <p class="text-slate-600 mt-1">
                        Contract with {$user?.id === contract.client.id
                            ? contract.freelancer.name
                            : contract.client.name}
                    </p>
                </div>
                <span
                    class="badge-{contract.status === 'active'
                        ? 'success'
                        : 'gray'} text-sm"
                >
                    {contract.status}
                </span>
            </div>
        </div>

        <!-- Stats -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <div class="card p-4">
                <p class="text-sm text-slate-500">Total Value</p>
                <p class="text-xl font-bold text-slate-900">
                    {formatCurrency(contract.total_amount)}
                </p>
            </div>
            <div class="card p-4">
                <p class="text-sm text-slate-500">Paid into Escrow</p>
                <p class="text-xl font-bold text-primary-600">
                    {formatCurrency(contract.total_paid)}
                </p>
            </div>
            <div class="card p-4">
                <p class="text-sm text-slate-500">Released to Freelancer</p>
                <p class="text-xl font-bold text-green-600">
                    {formatCurrency(contract.total_released)}
                </p>
            </div>
            <div class="card p-4">
                <p class="text-sm text-slate-500">Progress</p>
                <p class="text-xl font-bold text-slate-900">
                    {Math.round(
                        (contract.total_released / contract.total_amount) * 100,
                    )}%
                </p>
            </div>
        </div>

        <!-- Milestones -->
        <div class="card">
            <div
                class="p-6 border-b border-slate-100 flex items-center justify-between"
            >
                <h2 class="text-lg font-semibold text-slate-900">Milestones</h2>
                {#if $user?.id === contract.client.id && contract.status === "active"}
                    <button
                        on:click={openCreateModal}
                        class="btn-primary btn-sm"
                    >
                        + Add Milestone
                    </button>
                {/if}
            </div>

            {#if contract.milestones && contract.milestones.length > 0}
                <div class="divide-y divide-slate-100">
                    {#each contract.milestones as milestone}
                        {@const actions = getMilestoneActions(milestone)}
                        <div class="p-6">
                            <div class="flex items-start justify-between mb-3">
                                <div class="flex-1">
                                    <div class="flex items-center gap-3 mb-1">
                                        <h3 class="font-medium text-slate-900">
                                            {milestone.title}
                                        </h3>
                                        <span
                                            class={getStatusColor(
                                                milestone.status,
                                            )}>{milestone.status}</span
                                        >
                                        {#if milestone.overdue}
                                            <span class="badge-error"
                                                >Overdue</span
                                            >
                                        {/if}
                                    </div>
                                    {#if milestone.description}
                                        <p class="text-sm text-slate-600">
                                            {milestone.description}
                                        </p>
                                    {/if}
                                </div>
                                <div class="text-right">
                                    <p class="font-semibold text-slate-900">
                                        {formatCurrency(milestone.amount)}
                                    </p>
                                    <p class="text-sm text-slate-500">
                                        Due {formatDate(milestone.due_date)}
                                    </p>
                                </div>
                            </div>

                            <!-- Actions -->
                            <div class="flex gap-2 mt-4">
                                {#if actions.canPay}
                                    <button
                                        on:click={() =>
                                            openPaymentModal(milestone)}
                                        class="btn-primary btn-sm"
                                    >
                                        💳 Pay Now
                                    </button>
                                {/if}
                                {#if actions.canDeliver}
                                    <button
                                        on:click={() =>
                                            markDelivered(milestone)}
                                        class="btn-primary btn-sm"
                                    >
                                        ✅ Mark Delivered
                                    </button>
                                {/if}
                                {#if actions.canRelease}
                                    <button
                                        on:click={() => releaseFunds(milestone)}
                                        class="btn-accent btn-sm"
                                    >
                                        💰 Release Funds
                                    </button>
                                {/if}
                            </div>
                        </div>
                    {/each}
                </div>
            {:else}
                <div class="p-12 text-center text-slate-500">
                    <p>No milestones created yet</p>
                </div>
            {/if}
        </div>

        <!-- Actions -->
        <div class="mt-6 flex gap-4">
            <a
                href="/chat?user={$user?.id === contract.client.id
                    ? contract.freelancer.id
                    : contract.client.id}"
                class="btn-secondary"
            >
                💬 Message
            </a>
            {#if contract.status === "completed"}
                <a href="/contracts/{contract.id}/review" class="btn-primary">
                    ⭐ Leave Review
                </a>
            {/if}
        </div>
    </div>

    <!-- Payment Modal -->
    {#if showPaymentModal && selectedMilestone}
        <div
            class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
            on:click={closePaymentModal}
            on:keydown={(e) => e.key === "Escape" && closePaymentModal()}
            role="dialog"
            tabindex="-1"
        >
            <div
                class="card w-full max-w-md p-6 animate-scale-in"
                on:click={stopPropagation}
                on:keydown={stopPropagation}
                role="document"
            >
                <h2 class="text-xl font-display font-bold text-slate-900 mb-2">
                    Pay Milestone
                </h2>
                <p class="text-slate-600 mb-6">{selectedMilestone.title}</p>

                {#if paymentSuccess}
                    <div class="text-center py-8">
                        <div
                            class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4"
                        >
                            <svg
                                class="w-8 h-8 text-green-600"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M5 13l4 4L19 7"
                                />
                            </svg>
                        </div>
                        <h3 class="text-lg font-medium text-slate-900 mb-2">
                            Payment Successful!
                        </h3>
                        <p class="text-slate-600">
                            The funds are now held in escrow.
                        </p>
                    </div>
                {:else}
                    <div class="space-y-4">
                        <div class="p-4 bg-slate-50 rounded-lg">
                            <div class="flex justify-between mb-2">
                                <span class="text-slate-600">Amount</span>
                                <span class="font-semibold text-slate-900"
                                    >{formatCurrency(
                                        selectedMilestone.amount,
                                    )}</span
                                >
                            </div>
                            <div class="flex justify-between text-sm">
                                <span class="text-slate-500"
                                    >Platform fee (0%)</span
                                >
                                <span class="text-slate-500">$0.00</span>
                            </div>
                        </div>

                        {#if paymentError}
                            <div
                                class="p-3 bg-red-50 border border-red-100 rounded-lg text-red-600 text-sm"
                            >
                                {paymentError}
                            </div>
                        {/if}

                        <div>
                            <label
                                class="block text-sm font-medium text-slate-700 mb-2"
                                >Card Details</label
                            >
                            <div
                                id="card-element"
                                class="input p-3 min-h-[44px]"
                            ></div>
                        </div>

                        <div class="flex gap-3">
                            <button
                                type="button"
                                on:click={closePaymentModal}
                                class="btn-secondary flex-1"
                            >
                                Cancel
                            </button>
                            <button
                                on:click={processPayment}
                                disabled={paymentLoading}
                                class="btn-primary flex-1"
                            >
                                {#if paymentLoading}
                                    Processing...
                                {:else}
                                    Pay {formatCurrency(
                                        selectedMilestone.amount,
                                    )}
                                {/if}
                            </button>
                        </div>

                        <p class="text-xs text-slate-500 text-center">
                            🔒 Secure payment powered by Stripe (Test Mode)
                        </p>
                    </div>
                {/if}
            </div>
        </div>
    {/if}

    <!-- Create Milestone Modal -->
    {#if showCreateModal}
        <div
            class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
            on:click={closeCreateModal}
            on:keydown={(e) => e.key === "Escape" && closeCreateModal()}
            role="dialog"
            tabindex="-1"
        >
            <div
                class="card w-full max-w-md p-6 animate-scale-in"
                on:click={stopPropagation}
                on:keydown={stopPropagation}
                role="document"
            >
                <h2 class="text-xl font-display font-bold text-slate-900 mb-6">
                    Create Milestone
                </h2>

                <form on:submit|preventDefault={createMilestoneHandler}>
                    <div class="space-y-4">
                        <div>
                            <label
                                class="block text-sm font-medium text-slate-700 mb-1"
                                >Title</label
                            >
                            <input
                                type="text"
                                bind:value={newMilestone.title}
                                required
                                class="input"
                                placeholder="e.g., Design Phase"
                            />
                        </div>

                        <div>
                            <label
                                class="block text-sm font-medium text-slate-700 mb-1"
                                >Description</label
                            >
                            <textarea
                                bind:value={newMilestone.description}
                                rows="3"
                                class="input"
                                placeholder="What needs to be delivered..."
                            ></textarea>
                        </div>

                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label
                                    class="block text-sm font-medium text-slate-700 mb-1"
                                    >Amount</label
                                >
                                <div class="relative">
                                    <span
                                        class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
                                        >$</span
                                    >
                                    <input
                                        type="number"
                                        bind:value={newMilestone.amount}
                                        required
                                        min="1"
                                        class="input pl-8"
                                    />
                                </div>
                            </div>
                            <div>
                                <label
                                    class="block text-sm font-medium text-slate-700 mb-1"
                                    >Due Date</label
                                >
                                <input
                                    type="date"
                                    bind:value={newMilestone.due_date}
                                    required
                                    class="input"
                                />
                            </div>
                        </div>
                    </div>

                    <div class="flex gap-3 mt-6">
                        <button
                            type="button"
                            on:click={closeCreateModal}
                            class="btn-secondary flex-1"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={createLoading}
                            class="btn-primary flex-1"
                        >
                            {createLoading ? "Creating..." : "Create Milestone"}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    {/if}
{/if}
