<script lang="ts">
    import { auth } from "$lib/stores/auth";
    import { goto } from "$app/navigation";
    import { page } from "$app/stores";

    let name = "";
    let email = "";
    let password = "";
    let passwordConfirmation = "";
    let role: "freelancer" | "client" = "freelancer";
    let error = "";
    let errors: Record<string, string[]> = {};
    let isLoading = false;

    // Get role from URL if provided
    $: {
        const urlRole = $page.url.searchParams.get("role");
        if (urlRole === "client" || urlRole === "freelancer") {
            role = urlRole;
        }
    }

    async function handleSubmit(e: Event) {
        e.preventDefault();
        error = "";
        errors = {};

        if (password !== passwordConfirmation) {
            error = "Passwords do not match";
            return;
        }

        isLoading = true;

        const result = await auth.signUp({
            name,
            email,
            password,
            password_confirmation: passwordConfirmation,
            role,
        });

        if (result.success) {
            goto("/dashboard");
        } else {
            error = result.error || "Registration failed";
            errors = result.errors || {};
        }

        isLoading = false;
    }

    function selectRole(newRole: "freelancer" | "client") {
        role = newRole;
    }
</script>

<svelte:head>
    <title>Create Account - NomadHire</title>
</svelte:head>

<div class="min-h-[80vh] flex items-center justify-center py-16 px-4">
    <div class="w-full max-w-md">
        <div class="card p-8">
            <div class="text-center mb-8">
                <h1 class="text-2xl font-display font-bold text-slate-900 mb-2">
                    Create Your Account
                </h1>
                <p class="text-slate-600">
                    Join thousands of professionals on NomadHire
                </p>
            </div>

            {#if error}
                <div
                    class="mb-6 p-4 bg-red-50 border border-red-100 rounded-lg text-red-600 text-sm"
                >
                    {error}
                </div>
            {/if}

            <!-- Role Selection -->
            <div class="mb-6">
                <label class="block text-sm font-medium text-slate-700 mb-3">
                    I want to...
                </label>
                <div class="grid grid-cols-2 gap-4">
                    <button
                        type="button"
                        on:click={() => selectRole("freelancer")}
                        class="p-4 border-2 rounded-lg text-center transition-all {role ===
                        'freelancer'
                            ? 'border-primary-500 bg-primary-50'
                            : 'border-slate-200 hover:border-slate-300'}"
                    >
                        <div class="text-2xl mb-2">💼</div>
                        <div class="font-medium text-slate-900">Find Work</div>
                        <div class="text-xs text-slate-500">
                            I'm a freelancer
                        </div>
                    </button>
                    <button
                        type="button"
                        on:click={() => selectRole("client")}
                        class="p-4 border-2 rounded-lg text-center transition-all {role ===
                        'client'
                            ? 'border-primary-500 bg-primary-50'
                            : 'border-slate-200 hover:border-slate-300'}"
                    >
                        <div class="text-2xl mb-2">🎯</div>
                        <div class="font-medium text-slate-900">
                            Hire Talent
                        </div>
                        <div class="text-xs text-slate-500">I'm a client</div>
                    </button>
                </div>
            </div>

            <form on:submit|preventDefault={handleSubmit} class="space-y-5">
                <div>
                    <label
                        for="name"
                        class="block text-sm font-medium text-slate-700 mb-1"
                    >
                        Full Name
                    </label>
                    <input
                        type="text"
                        id="name"
                        bind:value={name}
                        required
                        minlength="2"
                        class="input {errors.name ? 'input-error' : ''}"
                        placeholder="John Doe"
                    />
                    {#if errors.name}
                        <p class="mt-1 text-xs text-red-500">
                            {errors.name[0]}
                        </p>
                    {/if}
                </div>

                <div>
                    <label
                        for="email"
                        class="block text-sm font-medium text-slate-700 mb-1"
                    >
                        Email Address
                    </label>
                    <input
                        type="email"
                        id="email"
                        bind:value={email}
                        required
                        class="input {errors.email ? 'input-error' : ''}"
                        placeholder="you@example.com"
                    />
                    {#if errors.email}
                        <p class="mt-1 text-xs text-red-500">
                            {errors.email[0]}
                        </p>
                    {/if}
                </div>

                <div>
                    <label
                        for="password"
                        class="block text-sm font-medium text-slate-700 mb-1"
                    >
                        Password
                    </label>
                    <input
                        type="password"
                        id="password"
                        bind:value={password}
                        required
                        minlength="6"
                        class="input {errors.password ? 'input-error' : ''}"
                        placeholder="At least 6 characters"
                    />
                    {#if errors.password}
                        <p class="mt-1 text-xs text-red-500">
                            {errors.password[0]}
                        </p>
                    {/if}
                </div>

                <div>
                    <label
                        for="password_confirmation"
                        class="block text-sm font-medium text-slate-700 mb-1"
                    >
                        Confirm Password
                    </label>
                    <input
                        type="password"
                        id="password_confirmation"
                        bind:value={passwordConfirmation}
                        required
                        class="input"
                        placeholder="Confirm your password"
                    />
                </div>

                <div class="flex items-start">
                    <input
                        type="checkbox"
                        required
                        class="w-4 h-4 mt-0.5 text-primary-600 border-slate-300 rounded focus:ring-primary-500"
                    />
                    <span class="ml-2 text-sm text-slate-600">
                        I agree to the <a
                            href="#"
                            class="text-primary-600 hover:underline"
                            >Terms of Service</a
                        >
                        and
                        <a href="#" class="text-primary-600 hover:underline"
                            >Privacy Policy</a
                        >
                    </span>
                </div>

                <button
                    type="submit"
                    disabled={isLoading}
                    class="btn-primary w-full py-3"
                >
                    {#if isLoading}
                        <svg
                            class="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline"
                            fill="none"
                            viewBox="0 0 24 24"
                        >
                            <circle
                                class="opacity-25"
                                cx="12"
                                cy="12"
                                r="10"
                                stroke="currentColor"
                                stroke-width="4"
                            ></circle>
                            <path
                                class="opacity-75"
                                fill="currentColor"
                                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                            ></path>
                        </svg>
                        Creating account...
                    {:else}
                        Create Account
                    {/if}
                </button>
            </form>

            <div class="mt-6 text-center">
                <p class="text-sm text-slate-600">
                    Already have an account?
                    <a
                        href="/auth/login"
                        class="text-primary-600 hover:text-primary-700 font-medium"
                    >
                        Sign in
                    </a>
                </p>
            </div>
        </div>
    </div>
</div>
