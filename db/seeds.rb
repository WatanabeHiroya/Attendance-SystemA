# coding: utf-8

User.create!(name: "Sample User",
             email: "sample@email.com",
             affiliation: "フリーランス部",
             employee_number: "1",
             uid: "1",
             superior: false,
             admin: true,
             password: "password",
             password_confirmation: "password")

User.create!(name: "test1",
             email: "test1@email.com",
             affiliation: "フリーランス部",
             employee_number: "2",
             uid: "2",
             basic_work_time: Time.current.change(hour: 8, min: 0, sec: 0),
             disignated_work_start_time: Time.current.change(hour: 9, min: 0, sec: 0),
             designated_work_end_time: Time.current.change(hour: 17, min: 0, sec: 0),
             superior: false,
             admin: false,
             password: "password",
             password_confirmation: "password")

