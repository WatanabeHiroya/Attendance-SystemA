# coding: utf-8

User.create!(name: "Sample User",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

User.create!(name: "",
             email: "",
             affiliation: "",
             employee_number: ,
             uid: ,
             basic_work_time: ,
             disignated_work_start_time: ,
             designated_work_end_time: ,
             superior: ,
             admin: false,
             password: "password")

