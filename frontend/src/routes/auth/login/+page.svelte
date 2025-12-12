<script lang="ts">
    import { auth } from "$lib/stores/auth";
    import { goto } from "$app/navigation";

    let email = "";
    let password = "";
    let error = "";
    let isLoading = false;

    async function handleSubmit(e: Event) {
        e.preventDefault();
        error = "";
        isLoading = true;

        const result = await auth.signIn({ email, password });

        if (result.success) {
            goto("/dashboard");
        } else {
            error = result.error || "Invalid email or password";
        }

        isLoading = false;
    }
</script>

<svelte:head>
    <title>Sign In - NomadHire</title>
</svelte:head>

<div class="min-h-[80vh] flex items-center justify-center py-16 px-4">
    <div class="w-full max-w-md">
        <div class="card p-8">
            <div class="text-center mb-8">
                <h1 class="text-2xl font-display font-bold text-slate-900 mb-2">
                    Welcome Back
                </h1>
                <p class="text-slate-600">
                    Sign in to your account to continue
                </p>
            </div>

            {#if error}
                <div
                    class="mb-6 p-4 bg-red-50 border border-red-100 rounded-lg text-red-600 text-sm"
                >
                    {error}
                </div>
            {/if}

            <form on:submit|preventDefault={handleSubmit} class="space-y-5">
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
                        class="input"
                        placeholder="you@example.com"
                    />
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
                        class="input"
                        placeholder="••••••••"
                    />
                </div>

                <div class="flex items-center justify-between">
                    <label class="flex items-center">
                        <input
                            type="checkbox"
                            class="w-4 h-4 text-primary-600 border-slate-300 rounded focus:ring-primary-500"
                        />
                        <span class="ml-2 text-sm text-slate-600"
                            >Remember me</span
                        >
                    </label>
                    <a
                        href="/auth/forgot-password"
                        class="text-sm text-primary-600 hover:text-primary-700"
                    >
                        Forgot password?
                    </a>
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
                        Signing in...
                    {:else}
                        Sign In
                    {/if}
                </button>
            </form>

            <div class="mt-6 text-center">
                <p class="text-sm text-slate-600">
                    Don't have an account?
                    <a
                        href="/auth/register"
                        class="text-primary-600 hover:text-primary-700 font-medium"
                    >
                        Sign up
                    </a>
                </p>
            </div>

            <!-- Demo accounts info -->
            <div
                class="mt-8 p-4 bg-slate-50 rounded-lg border border-slate-200"
            >
                <p class="text-xs font-medium text-slate-700 mb-2">
                    Demo Accounts:
                </p>
                <div class="text-xs text-slate-600 space-y-1">
                    <p>
                        <strong>Client:</strong> client@test.com / password123
                    </p>
                    <p>
                        <strong>Freelancer:</strong> freelancer@test.com / password123
                    </p>
                    <p><strong>Admin:</strong> admin@test.com / password123</p>
                </div>
            </div>
        </div>
    </div>
</div>
