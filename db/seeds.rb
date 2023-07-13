# coding: utf-8

User.create!(name: "Sample User",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)


             User.create!(name: "manager Sample User-1",
             email: "sample-1@email.com",
             password: "password",
             password_confirmation: "password",
             manager: true)
             
             User.create!(name: "manager Sample User-2",
             email: "sample-2@email.com",
             password: "password",
             password_confirmation: "password",
             manager: true)

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+3}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end