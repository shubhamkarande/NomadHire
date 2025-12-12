# frozen_string_literal: true

# Seeds for development and testing
# Run with: rails db:seed

puts "Seeding database..."

# Clear existing data in development
if Rails.env.development?
  puts "Clearing existing data..."
  Review.destroy_all
  Transaction.destroy_all
  Milestone.destroy_all
  Contract.destroy_all
  Bid.destroy_all
  JobSkill.destroy_all
  Job.destroy_all
  UserSkill.destroy_all
  Skill.destroy_all
  Message.destroy_all
  Conversation.destroy_all
  Notification.destroy_all
  User.destroy_all
end

# Create Skills
puts "Creating skills..."
skills = [
  'Ruby on Rails', 'JavaScript', 'TypeScript', 'React', 'Vue.js', 'Angular',
  'Node.js', 'Python', 'Django', 'Flask', 'PHP', 'Laravel',
  'PostgreSQL', 'MySQL', 'MongoDB', 'Redis', 'Docker', 'Kubernetes',
  'AWS', 'Azure', 'GCP', 'DevOps', 'CI/CD', 'Svelte',
  'GraphQL', 'REST API', 'Mobile Development', 'iOS', 'Android',
  'UI/UX Design', 'Figma', 'Adobe XD', 'Photoshop', 'Illustrator',
  'SEO', 'Digital Marketing', 'Content Writing', 'Copywriting',
  'Machine Learning', 'Data Science', 'Blockchain', 'Web3'
].map do |name|
  Skill.find_or_create_by!(name: name) do |skill|
    skill.slug = name.parameterize
  end
end

puts "Created #{skills.count} skills"

# Create Admin User
puts "Creating admin user..."
admin = User.create!(
  name: 'Admin User',
  email: 'admin@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: :admin,
  bio: 'Platform administrator',
  location: 'San Francisco, CA'
)

# Create Client Users
puts "Creating client users..."
clients = [
  {
    name: 'Sarah Johnson',
    email: 'client@test.com',
    bio: 'Startup founder looking for talented developers to build innovative products.',
    location: 'New York, NY'
  },
  {
    name: 'Michael Chen',
    email: 'michael@test.com',
    bio: 'Product manager at a tech company. Always looking for skilled freelancers.',
    location: 'Austin, TX'
  },
  {
    name: 'Emily Davis',
    email: 'emily@test.com',
    bio: 'E-commerce business owner needing help with web development and design.',
    location: 'Los Angeles, CA'
  }
].map do |attrs|
  User.create!(
    **attrs,
    password: 'password123',
    password_confirmation: 'password123',
    role: :client
  )
end

puts "Created #{clients.count} clients"

# Create Freelancer Users
puts "Creating freelancer users..."
freelancers = [
  {
    name: 'Alex Rivera',
    email: 'freelancer@test.com',
    bio: 'Full-stack developer with 5+ years of experience in Ruby on Rails and React.',
    hourly_rate: 85.00,
    location: 'Seattle, WA',
    rating_cache: 4.8,
    skills: ['Ruby on Rails', 'React', 'PostgreSQL', 'Docker']
  },
  {
    name: 'Jessica Kim',
    email: 'jessica@test.com',
    bio: 'Frontend specialist with expertise in modern JavaScript frameworks.',
    hourly_rate: 75.00,
    location: 'Portland, OR',
    rating_cache: 4.9,
    skills: ['JavaScript', 'TypeScript', 'React', 'Vue.js', 'Svelte']
  },
  {
    name: 'David Thompson',
    email: 'david@test.com',
    bio: 'Backend engineer focused on scalable APIs and microservices.',
    hourly_rate: 95.00,
    location: 'Denver, CO',
    rating_cache: 4.7,
    skills: ['Node.js', 'Python', 'PostgreSQL', 'MongoDB', 'Docker', 'AWS']
  },
  {
    name: 'Maria Garcia',
    email: 'maria@test.com',
    bio: 'UI/UX designer with a passion for creating beautiful user experiences.',
    hourly_rate: 70.00,
    location: 'Miami, FL',
    rating_cache: 4.9,
    skills: ['UI/UX Design', 'Figma', 'Adobe XD', 'Photoshop']
  },
  {
    name: 'James Wilson',
    email: 'james@test.com',
    bio: 'DevOps engineer specializing in cloud infrastructure and automation.',
    hourly_rate: 100.00,
    location: 'Chicago, IL',
    rating_cache: 4.6,
    skills: ['DevOps', 'AWS', 'Docker', 'Kubernetes', 'CI/CD']
  }
].map do |attrs|
  skill_names = attrs.delete(:skills)
  user = User.create!(
    **attrs,
    password: 'password123',
    password_confirmation: 'password123',
    role: :freelancer
  )
  
  # Add skills to freelancer
  skill_names.each do |skill_name|
    skill = Skill.find_by(name: skill_name)
    user.user_skills.create!(skill: skill) if skill
  end
  
  user
end

puts "Created #{freelancers.count} freelancers"

# Create Jobs
puts "Creating jobs..."
jobs = [
  {
    client: clients[0],
    title: 'Build a Modern E-commerce Platform',
    description: 'We are looking for an experienced full-stack developer to build a modern e-commerce platform. The platform should include product catalog, shopping cart, checkout, payment integration (Stripe), user authentication, order management, and admin dashboard. We prefer React for the frontend and Node.js or Ruby on Rails for the backend.',
    budget_min: 8000,
    budget_max: 12000,
    budget_type: :fixed,
    deadline: 60.days.from_now,
    skills: ['React', 'Node.js', 'PostgreSQL', 'Docker']
  },
  {
    client: clients[1],
    title: 'Mobile App Development - iOS and Android',
    description: 'Looking for a mobile developer to create a cross-platform fitness tracking app. Features include workout logging, progress tracking, social features, and integration with health APIs. React Native preferred.',
    budget_min: 50,
    budget_max: 80,
    budget_type: :hourly,
    deadline: 90.days.from_now,
    skills: ['Mobile Development', 'React', 'iOS', 'Android']
  },
  {
    client: clients[2],
    title: 'UI/UX Redesign for SaaS Dashboard',
    description: 'We need a talented designer to redesign our analytics dashboard. The current design is outdated and we want a modern, clean look with improved usability. Deliverables include Figma designs, design system, and component specifications.',
    budget_min: 3000,
    budget_max: 5000,
    budget_type: :fixed,
    deadline: 30.days.from_now,
    skills: ['UI/UX Design', 'Figma']
  },
  {
    client: clients[0],
    title: 'Backend API Development with Python',
    description: 'Need an experienced Python developer to build a REST API for our internal tools. The API will handle data processing, user management, and integration with third-party services. FastAPI or Django REST framework preferred.',
    budget_min: 5000,
    budget_max: 7500,
    budget_type: :fixed,
    deadline: 45.days.from_now,
    skills: ['Python', 'Django', 'REST API', 'PostgreSQL']
  },
  {
    client: clients[1],
    title: 'DevOps Setup and CI/CD Pipeline',
    description: 'Looking for a DevOps engineer to set up our AWS infrastructure and CI/CD pipeline. This includes Docker containerization, Kubernetes cluster setup, GitHub Actions workflows, and monitoring setup.',
    budget_min: 100,
    budget_max: 150,
    budget_type: :hourly,
    deadline: 21.days.from_now,
    skills: ['DevOps', 'AWS', 'Docker', 'Kubernetes', 'CI/CD']
  }
].map do |attrs|
  skill_names = attrs.delete(:skills)
  job = Job.create!(attrs)
  
  skill_names.each do |skill_name|
    skill = Skill.find_by(name: skill_name)
    job.job_skills.create!(skill: skill) if skill
  end
  
  job
end

puts "Created #{jobs.count} jobs"

# Create some bids
puts "Creating bids..."
bids = [
  { job: jobs[0], freelancer: freelancers[0], amount: 10000, estimated_days: 45, cover_letter: "I have extensive experience building e-commerce platforms with React and Rails. I've delivered similar projects for startups and established companies. I can start immediately and deliver a high-quality product within your timeline." },
  { job: jobs[0], freelancer: freelancers[2], amount: 11500, estimated_days: 50, cover_letter: "With my background in scalable backend systems and modern frontend frameworks, I can build a robust e-commerce solution. I'll use best practices for security, performance, and maintainability." },
  { job: jobs[1], freelancer: freelancers[1], amount: 65, estimated_days: 60, cover_letter: "I specialize in React Native development and have shipped multiple fitness apps. I'm familiar with HealthKit and Google Fit APIs. Let's discuss the requirements in detail." },
  { job: jobs[2], freelancer: freelancers[3], amount: 4000, estimated_days: 20, cover_letter: "As a UI/UX designer with 7+ years of experience, I've redesigned numerous SaaS dashboards. I focus on user research, usability testing, and creating design systems that scale." },
  { job: jobs[3], freelancer: freelancers[2], amount: 6500, estimated_days: 35, cover_letter: "Python and API development are my core strengths. I've built similar internal tools using FastAPI and Django. I follow test-driven development and write clean, documented code." },
  { job: jobs[4], freelancer: freelancers[4], amount: 120, estimated_days: 14, cover_letter: "DevOps is my specialty. I've set up production infrastructure for companies ranging from startups to enterprises. I can have your CI/CD pipeline running smoothly in no time." }
].map do |attrs|
  Bid.create!(**attrs, status: :pending)
end

puts "Created #{bids.count} bids"

# Accept one bid and create a contract
puts "Creating a contract..."
accepted_bid = bids[3] # UI/UX redesign bid
accepted_bid.accept!

contract = Contract.last

# Create milestones for the contract
puts "Creating milestones..."
milestones = [
  { title: 'Research & Discovery', description: 'User research, competitive analysis, and requirements gathering', amount: 1000, due_date: 7.days.from_now },
  { title: 'Wireframes & Low-fidelity Designs', description: 'Initial wireframes and layout concepts', amount: 1000, due_date: 14.days.from_now },
  { title: 'High-fidelity Designs', description: 'Complete visual designs in Figma', amount: 1500, due_date: 21.days.from_now },
  { title: 'Design System & Handoff', description: 'Component library and developer documentation', amount: 500, due_date: 28.days.from_now }
].map do |attrs|
  contract.milestones.create!(attrs)
end

puts "Created #{milestones.count} milestones"

# Create a conversation
puts "Creating conversations..."
conversation = Conversation.create!(
  participant_1: clients[2],
  participant_2: freelancers[3]
)

messages = [
  { sender: clients[2], body: "Hi Maria! Thanks for your bid on the dashboard redesign. Your portfolio looks impressive!" },
  { sender: freelancers[3], body: "Thank you, Emily! I'm really excited about this project. Your current dashboard has great potential." },
  { sender: clients[2], body: "Can we schedule a call this week to discuss the requirements in more detail?" },
  { sender: freelancers[3], body: "Absolutely! I'm available Thursday or Friday afternoon. What works best for you?" }
].each do |attrs|
  conversation.messages.create!(attrs)
end

puts "Created conversation with #{messages.count} messages"

# Create some notifications
puts "Creating notifications..."
Notification.create!(
  user: clients[2],
  kind: 'bid_accepted',
  payload: { job_id: jobs[2].id, job_title: jobs[2].title, freelancer_name: freelancers[3].name },
  read: true
)

puts "\n✅ Seeding complete!"
puts "\n📋 Test Accounts:"
puts "  Admin:      admin@test.com / password123"
puts "  Client:     client@test.com / password123"
puts "  Freelancer: freelancer@test.com / password123"
puts "\n💳 Test Payment Cards:"
puts "  Stripe:    4242 4242 4242 4242 (any future exp, any CVV)"
puts "  Razorpay:  4111 1111 1111 1111 (any future exp, any CVV)"
