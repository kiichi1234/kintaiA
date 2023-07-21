# coding: utf-8

User.create!(name: "Sample User",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "0001",
             admin: true)


             User.create!(name: "sample-managerA",
             email: "sample-managerA@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "0002",
             manager: true)
             
             User.create!(name: "sample-managerB",
             email: "sample-managerB@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "0003",
             manager: true)

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  employee_number = format('%02d', n + 1) * 2
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_number: employee_number)
end