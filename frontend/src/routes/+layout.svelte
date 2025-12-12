<script lang="ts">
  import { onMount } from "svelte";
  import { auth, isAuthenticated, user } from "$lib/stores/auth";
  import { notifications } from "$lib/stores/notifications";
  import { ws } from "$lib/websocket";
  import "../app.css";

  let mobileMenuOpen = false;
  let notificationDropdownOpen = false;
  let userMenuOpen = false;

  onMount(async () => {
    // Initialize auth
    await auth.init();

    // Initialize WebSocket and notifications if authenticated
    if ($isAuthenticated) {
      try {
        await ws.connect();
        await notifications.load();

        // Subscribe to notifications channel
        const identifier = ws.subscribe("NotificationsChannel");
        ws.on(identifier, "new_notification", (data: any) => {
          notifications.addNotification(data.notification);
        });
      } catch (e) {
        console.error("WebSocket connection failed:", e);
      }
    }
  });

  async function handleSignOut() {
    await auth.signOut();
    ws.disconnect();
    notifications.clear();
    window.location.href = "/";
  }

  function toggleMobileMenu() {
    mobileMenuOpen = !mobileMenuOpen;
  }

  function toggleNotifications() {
    notificationDropdownOpen = !notificationDropdownOpen;
    userMenuOpen = false;
  }

  function toggleUserMenu() {
    userMenuOpen = !userMenuOpen;
    notificationDropdownOpen = false;
  }
</script>

<svelte:head>
  <title>NomadHire - Freelancers Without Borders</title>
  <meta
    name="description"
    content="Connect with talented freelancers and clients worldwide. Find jobs, build your career, and grow your business."
  />
</svelte:head>

<div class="min-h-screen bg-slate-50">
  <!-- Navigation -->
  <nav
    class="bg-white/80 backdrop-blur-md border-b border-slate-100 sticky top-0 z-50"
  >
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between h-16">
        <!-- Logo -->
        <div class="flex items-center">
          <a href="/" class="flex items-center space-x-2">
            <div
              class="w-8 h-8 bg-gradient-to-br from-primary-500 to-primary-700 rounded-lg flex items-center justify-center"
            >
              <span class="text-white font-bold text-lg">N</span>
            </div>
            <span class="font-display font-bold text-xl text-slate-900"
              >NomadHire</span
            >
          </a>
        </div>

        <!-- Desktop Navigation -->
        <div class="hidden md:flex items-center space-x-8">
          <a
            href="/jobs"
            class="text-slate-600 hover:text-primary-600 font-medium transition-colors"
          >
            Browse Jobs
          </a>
          <a
            href="/freelancers"
            class="text-slate-600 hover:text-primary-600 font-medium transition-colors"
          >
            Find Talent
          </a>

          {#if $isAuthenticated}
            <a
              href="/dashboard"
              class="text-slate-600 hover:text-primary-600 font-medium transition-colors"
            >
              Dashboard
            </a>
            <a
              href="/chat"
              class="text-slate-600 hover:text-primary-600 font-medium transition-colors"
            >
              Messages
            </a>

            <!-- Notifications -->
            <div class="relative">
              <button
                on:click={toggleNotifications}
                class="relative p-2 text-slate-600 hover:text-primary-600 transition-colors"
              >
                <svg
                  class="w-6 h-6"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
                  />
                </svg>
                {#if $notifications.unreadCount > 0}
                  <span
                    class="absolute -top-1 -right-1 w-5 h-5 bg-error-500 text-white text-xs rounded-full flex items-center justify-center"
                  >
                    {$notifications.unreadCount}
                  </span>
                {/if}
              </button>
            </div>

            <!-- User Menu -->
            <div class="relative">
              <button
                on:click={toggleUserMenu}
                class="flex items-center space-x-2"
              >
                <div
                  class="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center"
                >
                  <span class="text-primary-600 font-medium text-sm">
                    {$user?.name?.charAt(0) || "U"}
                  </span>
                </div>
                <svg
                  class="w-4 h-4 text-slate-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </button>

              {#if userMenuOpen}
                <div
                  class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-slate-100 py-1 animate-slide-down"
                >
                  <div class="px-4 py-2 border-b border-slate-100">
                    <p class="text-sm font-medium text-slate-900">
                      {$user?.name}
                    </p>
                    <p class="text-xs text-slate-500">{$user?.email}</p>
                  </div>
                  <a
                    href="/profile"
                    class="block px-4 py-2 text-sm text-slate-700 hover:bg-slate-50"
                  >
                    Profile
                  </a>
                  <a
                    href="/contracts"
                    class="block px-4 py-2 text-sm text-slate-700 hover:bg-slate-50"
                  >
                    Contracts
                  </a>
                  {#if $user?.role === "admin"}
                    <a
                      href="/admin"
                      class="block px-4 py-2 text-sm text-slate-700 hover:bg-slate-50"
                    >
                      Admin Panel
                    </a>
                  {/if}
                  <button
                    on:click={handleSignOut}
                    class="w-full text-left px-4 py-2 text-sm text-error-600 hover:bg-red-50"
                  >
                    Sign Out
                  </button>
                </div>
              {/if}
            </div>
          {:else}
            <a href="/auth/login" class="btn-ghost"> Sign In </a>
            <a href="/auth/register" class="btn-primary"> Get Started </a>
          {/if}
        </div>

        <!-- Mobile menu button -->
        <div class="md:hidden flex items-center">
          <button on:click={toggleMobileMenu} class="p-2 text-slate-600">
            <svg
              class="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 6h16M4 12h16M4 18h16"
              />
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Mobile menu -->
    {#if mobileMenuOpen}
      <div
        class="md:hidden border-t border-slate-100 bg-white animate-slide-down"
      >
        <div class="px-4 py-3 space-y-2">
          <a href="/jobs" class="block py-2 text-slate-600">Browse Jobs</a>
          <a href="/freelancers" class="block py-2 text-slate-600"
            >Find Talent</a
          >
          {#if $isAuthenticated}
            <a href="/dashboard" class="block py-2 text-slate-600">Dashboard</a>
            <a href="/chat" class="block py-2 text-slate-600">Messages</a>
            <button on:click={handleSignOut} class="block py-2 text-error-600"
              >Sign Out</button
            >
          {:else}
            <a href="/auth/login" class="block py-2 text-slate-600">Sign In</a>
            <a href="/auth/register" class="btn-primary w-full text-center mt-2"
              >Get Started</a
            >
          {/if}
        </div>
      </div>
    {/if}
  </nav>

  <!-- Main Content -->
  <main>
    <slot />
  </main>

  <!-- Footer -->
  <footer class="bg-slate-900 text-slate-300 mt-auto">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
        <div>
          <div class="flex items-center space-x-2 mb-4">
            <div
              class="w-8 h-8 bg-gradient-to-br from-primary-500 to-primary-700 rounded-lg flex items-center justify-center"
            >
              <span class="text-white font-bold text-lg">N</span>
            </div>
            <span class="font-display font-bold text-xl text-white"
              >NomadHire</span
            >
          </div>
          <p class="text-sm">
            Connect with talented freelancers and clients worldwide.
          </p>
        </div>

        <div>
          <h4 class="font-semibold text-white mb-4">For Clients</h4>
          <ul class="space-y-2 text-sm">
            <li>
              <a href="/jobs/new" class="hover:text-primary-400">Post a Job</a>
            </li>
            <li>
              <a href="/freelancers" class="hover:text-primary-400"
                >Find Freelancers</a
              >
            </li>
            <li><a href="#" class="hover:text-primary-400">How it Works</a></li>
          </ul>
        </div>

        <div>
          <h4 class="font-semibold text-white mb-4">For Freelancers</h4>
          <ul class="space-y-2 text-sm">
            <li>
              <a href="/jobs" class="hover:text-primary-400">Browse Jobs</a>
            </li>
            <li>
              <a href="#" class="hover:text-primary-400">Create Profile</a>
            </li>
            <li><a href="#" class="hover:text-primary-400">Resources</a></li>
          </ul>
        </div>

        <div>
          <h4 class="font-semibold text-white mb-4">Company</h4>
          <ul class="space-y-2 text-sm">
            <li><a href="#" class="hover:text-primary-400">About Us</a></li>
            <li>
              <a href="#" class="hover:text-primary-400">Privacy Policy</a>
            </li>
            <li>
              <a href="#" class="hover:text-primary-400">Terms of Service</a>
            </li>
          </ul>
        </div>
      </div>

      <div class="border-t border-slate-800 mt-8 pt-8 text-sm text-center">
        <p>© 2024 NomadHire. All rights reserved.</p>
      </div>
    </div>
  </footer>
</div>
