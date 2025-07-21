<script lang="ts">
  import { ArrowRight, Users, Briefcase, DollarSign, Star } from 'lucide-svelte'
  import Button from '../lib/components/Button.svelte'
  import Card from '../lib/components/Card.svelte'

  const stats = [
    { label: 'Active Freelancers', value: 50000, icon: Users },
    { label: 'Projects Completed', value: 25000, icon: Briefcase },
    { label: 'Total Earnings', value: 10000000, icon: DollarSign, prefix: '$' }
  ]

  const features = [
    {
      title: 'Global Talent Pool',
      description: 'Access skilled freelancers from around the world, bringing diverse perspectives to your projects.',
      icon: Users
    },
    {
      title: 'Secure Payments',
      description: 'Protected milestone-based payments ensure fair compensation and project completion.',
      icon: DollarSign
    },
    {
      title: 'Quality Assurance',
      description: 'Verified profiles, skills tests, and review systems maintain high quality standards.',
      icon: Star
    },
    {
      title: 'Project Management',
      description: 'Built-in tools for communication, file sharing, and milestone tracking.',
      icon: Briefcase
    }
  ]

  const testimonials = [
    {
      name: 'Sarah Chen',
      role: 'Startup Founder',
      content: 'NomadHire helped us find incredible developers who understood our vision. The milestone system gave us confidence throughout the project.',
      avatar: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&dpr=2'
    },
    {
      name: 'Marcus Rodriguez',
      role: 'Freelance Designer',
      content: 'As a freelancer, I love the transparent bidding process and secure payment system. It has helped me build a sustainable remote career.',
      avatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&dpr=2'
    },
    {
      name: 'Emily Watson',
      role: 'Agency Owner',
      content: 'The quality of talent on NomadHire is exceptional. We have completed dozens of projects with outstanding results.',
      avatar: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&dpr=2'
    }
  ]
</script>

<!-- Hero Section -->
<section class="relative bg-gradient-to-br from-primary-600 to-secondary-600 text-white overflow-hidden">
  <div class="absolute inset-0 bg-black opacity-10"></div>
  <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-32">
    <div class="text-center">
      <h1 class="text-4xl sm:text-5xl lg:text-6xl font-bold mb-6 leading-tight">
        Freelancers Without
        <span class="text-accent-400">Borders</span>
      </h1>
      <p class="text-xl lg:text-2xl mb-8 max-w-3xl mx-auto text-gray-100">
        Connect with top talent worldwide or find your next big opportunity. 
        Build, create, and scale with NomadHire's global freelance community.
      </p>
      <div class="flex flex-col sm:flex-row gap-4 justify-center items-center">
        <Button size="lg" href="/signup">
          Get Started Free
          <ArrowRight size={20} class="ml-2" />
        </Button>
        <Button variant="outline" size="lg" href="/browse">
          Browse Projects
        </Button>
      </div>
    </div>
  </div>

</section>

<!-- Stats Section -->
<section class="py-16 bg-white dark:bg-gray-900">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
      {#each stats as stat}
        <div class="text-center">
          <div class="flex justify-center mb-4">
            <div class="w-16 h-16 bg-primary-100 dark:bg-primary-900 rounded-full flex items-center justify-center">
              <svelte:component this={stat.icon} size={32} class="text-primary-600 dark:text-primary-400" />
            </div>
          </div>
          <div class="text-3xl lg:text-4xl font-bold text-gray-900 dark:text-white mb-2">
            {#if stat.prefix}{stat.prefix}{/if}{stat.value.toLocaleString()}
          </div>
          <p class="text-gray-600 dark:text-gray-400 font-medium">{stat.label}</p>
        </div>
      {/each}
    </div>
  </div>
</section>

<!-- Features Section -->
<section class="py-20 bg-gray-50 dark:bg-gray-800">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16">
      <h2 class="text-3xl lg:text-4xl font-bold text-gray-900 dark:text-white mb-4">
        Why Choose NomadHire?
      </h2>
      <p class="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
        We've built the ultimate platform for remote collaboration, 
        bringing together the best features for freelancers and clients.
      </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
      {#each features as feature}
        <Card hover padding="lg">
          <div class="text-center">
            <div class="flex justify-center mb-4">
              <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900 rounded-lg flex items-center justify-center">
                <svelte:component this={feature.icon} size={24} class="text-primary-600 dark:text-primary-400" />
              </div>
            </div>
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
              {feature.title}
            </h3>
            <p class="text-gray-600 dark:text-gray-400">
              {feature.description}
            </p>
          </div>
        </Card>
      {/each}
    </div>
  </div>
</section>

<!-- How It Works Section -->
<section class="py-20 bg-white dark:bg-gray-900">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16">
      <h2 class="text-3xl lg:text-4xl font-bold text-gray-900 dark:text-white mb-4">
        How It Works
      </h2>
      <p class="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
        Get started in three simple steps
      </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
      <div class="text-center">
        <div class="w-16 h-16 bg-primary-600 text-white rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-6">
          1
        </div>
        <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Create Your Profile</h3>
        <p class="text-gray-600 dark:text-gray-400">
          Sign up as a freelancer or client and showcase your skills or project requirements
        </p>
      </div>
      <div class="text-center">
        <div class="w-16 h-16 bg-secondary-600 text-white rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-6">
          2
        </div>
        <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Connect & Collaborate</h3>
        <p class="text-gray-600 dark:text-gray-400">
          Browse projects, submit proposals, or hire talent. Use our built-in communication tools
        </p>
      </div>
      <div class="text-center">
        <div class="w-16 h-16 bg-accent-600 text-white rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-6">
          3
        </div>
        <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Get Paid Securely</h3>
        <p class="text-gray-600 dark:text-gray-400">
          Complete milestones and receive secure payments through our protected system
        </p>
      </div>
    </div>
  </div>
</section>

<!-- Testimonials Section -->
<section class="py-20 bg-gray-50 dark:bg-gray-800">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16">
      <h2 class="text-3xl lg:text-4xl font-bold text-gray-900 dark:text-white mb-4">
        What Our Users Say
      </h2>
      <p class="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
        Join thousands of satisfied freelancers and clients
      </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
      {#each testimonials as testimonial}
        <Card padding="lg" shadow="lg">
          <div>
            <div class="flex items-center mb-4">
              {#each Array(5) as _}
                <Star size={16} class="text-warning-400 fill-current" />
              {/each}
            </div>
            <blockquote class="text-gray-600 dark:text-gray-400 mb-6 italic">
              "{testimonial.content}"
            </blockquote>
            <div class="flex items-center">
              <img
                src={testimonial.avatar}
                alt={testimonial.name}
                class="w-12 h-12 rounded-full mr-4 object-cover"
              />
              <div>
                <p class="font-semibold text-gray-900 dark:text-white">{testimonial.name}</p>
                <p class="text-sm text-gray-500 dark:text-gray-400">{testimonial.role}</p>
              </div>
            </div>
          </div>
        </Card>
      {/each}
    </div>
  </div>
</section>

<!-- CTA Section -->
<section class="py-20 bg-gradient-to-r from-primary-600 to-secondary-600 text-white">
  <div class="max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
    <h2 class="text-3xl lg:text-4xl font-bold mb-6">
      Ready to Start Your Journey?
    </h2>
    <p class="text-xl mb-8 text-gray-100">
      Join the global community of freelancers and clients building the future of work.
    </p>
    <div class="flex flex-col sm:flex-row gap-4 justify-center">
      <Button size="lg" variant="outline" href="/signup">
        Join as Freelancer
      </Button>
      <Button size="lg" href="/signup">
        Hire Talent Now
        <ArrowRight size={20} class="ml-2" />
      </Button>
    </div>
  </div>
</section>