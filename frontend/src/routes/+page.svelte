<script lang="ts">
    import { onMount } from "svelte";

    let heroVisible = false;
    let featuresVisible = false;

    onMount(() => {
        // Simple fade-in on mount
        heroVisible = true;

        setTimeout(() => {
            featuresVisible = true;
        }, 300);
    });

    const features = [
        {
            icon: "🎯",
            title: "Find Perfect Matches",
            description:
                "Advanced matching algorithm connects you with the right freelancers or projects.",
        },
        {
            icon: "💰",
            title: "Secure Payments",
            description:
                "Escrow protection ensures safe transactions for both clients and freelancers.",
        },
        {
            icon: "💬",
            title: "Real-time Communication",
            description:
                "Built-in chat keeps you connected with instant messaging and file sharing.",
        },
        {
            icon: "📊",
            title: "Milestone Tracking",
            description:
                "Break projects into milestones for better progress tracking and payments.",
        },
        {
            icon: "⭐",
            title: "Reviews & Ratings",
            description:
                "Build your reputation with a transparent review system.",
        },
        {
            icon: "🌍",
            title: "Global Talent Pool",
            description: "Access skilled professionals from around the world.",
        },
    ];

    const stats = [
        { value: "10K+", label: "Active Freelancers" },
        { value: "5K+", label: "Jobs Posted" },
        { value: "$2M+", label: "Paid to Freelancers" },
        { value: "4.8", label: "Average Rating" },
    ];
</script>

<svelte:head>
    <title>NomadHire - Freelancers Without Borders</title>
    <meta
        name="description"
        content="Connect with talented freelancers worldwide. Post jobs, hire talent, and build your dream team with NomadHire."
    />
</svelte:head>

<!-- Hero Section -->
<section
    class="relative overflow-hidden gradient-hero text-white"
    style="background: linear-gradient(to bottom right, #0f172a, #0c4a6e, #0f172a);"
>
    <!-- Background decoration -->
    <div class="absolute inset-0 overflow-hidden">
        <div
            class="absolute -top-40 -right-40 w-80 h-80 bg-primary-500/20 rounded-full blur-3xl animate-float"
        ></div>
        <div
            class="absolute top-1/2 -left-20 w-60 h-60 bg-secondary-500/20 rounded-full blur-3xl animate-float"
            style="animation-delay: -2s;"
        ></div>
        <div
            class="absolute bottom-0 right-1/4 w-96 h-96 bg-accent-500/10 rounded-full blur-3xl animate-float"
            style="animation-delay: -4s;"
        ></div>
    </div>

    <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 md:py-32">
        <div class="text-center max-w-4xl mx-auto">
            <h1
                class="hero-title font-display text-4xl md:text-6xl lg:text-7xl font-bold mb-6 leading-tight"
            >
                Freelancers
                <span
                    class="text-gradient bg-gradient-to-r from-primary-300 to-secondary-300 bg-clip-text text-transparent"
                >
                    Without Borders
                </span>
            </h1>

            <p
                class="hero-subtitle text-lg md:text-xl text-slate-300 mb-10 max-w-2xl mx-auto leading-relaxed"
            >
                Connect with talented professionals worldwide. Whether you're
                looking to hire or get hired, NomadHire makes it easy to find
                your perfect match.
            </p>

            <div
                class="hero-cta flex flex-col sm:flex-row gap-4 justify-center"
            >
                <a
                    href="/auth/register"
                    class="btn-primary btn-lg shadow-glow-lg hover:shadow-glow transition-all"
                >
                    Start Hiring Today
                    <svg
                        class="w-5 h-5 ml-2"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M13 7l5 5m0 0l-5 5m5-5H6"
                        />
                    </svg>
                </a>
                <a
                    href="/jobs"
                    class="btn bg-white/10 hover:bg-white/20 text-white border border-white/20 btn-lg backdrop-blur-sm"
                >
                    Browse Jobs
                </a>
            </div>
        </div>

        <!-- Stats -->
        <div
            class="mt-20 grid grid-cols-2 md:grid-cols-4 gap-8 max-w-3xl mx-auto"
        >
            {#each stats as stat}
                <div class="stat-item text-center">
                    <div class="text-3xl md:text-4xl font-bold text-white mb-1">
                        {stat.value}
                    </div>
                    <div class="text-sm text-slate-400">{stat.label}</div>
                </div>
            {/each}
        </div>
    </div>

    <!-- Wave decoration -->
    <div class="absolute bottom-0 left-0 right-0">
        <svg
            viewBox="0 0 1440 120"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
        >
            <path
                d="M0 120L60 110C120 100 240 80 360 70C480 60 600 60 720 65C840 70 960 80 1080 85C1200 90 1320 90 1380 90L1440 90V120H1380C1320 120 1200 120 1080 120C960 120 840 120 720 120C600 120 480 120 360 120C240 120 120 120 60 120H0Z"
                fill="#f8fafc"
            />
        </svg>
    </div>
</section>

<!-- Features Section -->
<section class="section bg-slate-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
            <h2
                class="text-3xl md:text-4xl font-display font-bold text-slate-900 mb-4"
            >
                Everything You Need to Succeed
            </h2>
            <p class="text-lg text-slate-600 max-w-2xl mx-auto">
                Powerful features designed to make freelancing and hiring
                seamless.
            </p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {#each features as feature}
                <div class="feature-card card card-hover p-6">
                    <div
                        class="w-14 h-14 bg-gradient-to-br from-primary-100 to-primary-50 rounded-xl flex items-center justify-center text-2xl mb-4"
                    >
                        {feature.icon}
                    </div>
                    <h3 class="text-xl font-semibold text-slate-900 mb-2">
                        {feature.title}
                    </h3>
                    <p class="text-slate-600">{feature.description}</p>
                </div>
            {/each}
        </div>
    </div>
</section>

<!-- How It Works -->
<section class="section bg-white">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
            <h2
                class="text-3xl md:text-4xl font-display font-bold text-slate-900 mb-4"
            >
                How It Works
            </h2>
            <p class="text-lg text-slate-600">
                Get started in minutes with our simple process.
            </p>
        </div>

        <div class="grid md:grid-cols-3 gap-12">
            <div class="text-center">
                <div
                    class="w-16 h-16 bg-primary-600 rounded-full flex items-center justify-center text-white text-2xl font-bold mx-auto mb-6"
                >
                    1
                </div>
                <h3 class="text-xl font-semibold text-slate-900 mb-3">
                    Create Your Profile
                </h3>
                <p class="text-slate-600">
                    Sign up and showcase your skills, experience, and portfolio
                    to attract the right opportunities.
                </p>
            </div>

            <div class="text-center">
                <div
                    class="w-16 h-16 bg-primary-600 rounded-full flex items-center justify-center text-white text-2xl font-bold mx-auto mb-6"
                >
                    2
                </div>
                <h3 class="text-xl font-semibold text-slate-900 mb-3">
                    Connect & Collaborate
                </h3>
                <p class="text-slate-600">
                    Browse jobs, submit proposals, or post projects. Our
                    matching system helps you find perfect fits.
                </p>
            </div>

            <div class="text-center">
                <div
                    class="w-16 h-16 bg-primary-600 rounded-full flex items-center justify-center text-white text-2xl font-bold mx-auto mb-6"
                >
                    3
                </div>
                <h3 class="text-xl font-semibold text-slate-900 mb-3">
                    Get Paid Securely
                </h3>
                <p class="text-slate-600">
                    Complete milestones and receive payments through our secure
                    escrow system.
                </p>
            </div>
        </div>
    </div>
</section>

<!-- CTA Section -->
<section class="section gradient-primary text-white">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 class="text-3xl md:text-4xl font-display font-bold mb-6">
            Ready to Start Your Journey?
        </h2>
        <p class="text-lg text-primary-100 mb-8 max-w-2xl mx-auto">
            Join thousands of freelancers and clients who are already building
            amazing things together.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <a
                href="/auth/register?role=client"
                class="btn bg-white text-primary-600 hover:bg-primary-50 btn-lg"
            >
                I'm a Client
            </a>
            <a
                href="/auth/register?role=freelancer"
                class="btn bg-primary-700 text-white hover:bg-primary-800 border border-primary-500 btn-lg"
            >
                I'm a Freelancer
            </a>
        </div>
    </div>
</section>
