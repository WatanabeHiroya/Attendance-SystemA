# coding: utf-8

User.create!(name: "管理者",
             email: "admin@email.com",
             affiliation: "フリーランス部",
             employee_number: "1",
             uid: "1",
             superior: false,
             admin: true,
             password: "password",
             password_confirmation: "password")

User.create!(name: "上長1",
             email: "superior1@email.com",
             affiliation: "フリーランス部",
             employee_number: "2",
             uid: "2",
             basic_work_time: Time.current.change(hour: 8, min: 0, sec: 0),
             designated_work_start_time: Time.current.change(hour: 9, min: 0, sec: 0),
             designated_work_end_time: Time.current.change(hour: 17, min: 0, sec: 0),
             superior: true,
             admin: false,
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "上長2",
             email: "superior2@email.com",
             affiliation: "フリーランス部",
             employee_number: "3",
             uid: "3",
             basic_work_time: Time.current.change(hour: 8, min: 0, sec: 0),
             designated_work_start_time: Time.current.change(hour: 9, min: 0, sec: 0),
             designated_work_end_time: Time.current.change(hour: 17, min: 0, sec: 0),
             superior: true,
             admin: false,
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "一般1",
             email: "sample1@email.com",
             affiliation: "フリーランス部",
             employee_number: "4",
             uid: "4",
             basic_work_time: Time.current.change(hour: 8, min: 0, sec: 0),
             designated_work_start_time: Time.current.change(hour: 9, min: 0, sec: 0),
             designated_work_end_time: Time.current.change(hour: 17, min: 0, sec: 0),
             superior: false,
             admin: false,
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "一般2",
             email: "sample2@email.com",
             affiliation: "フリーランス部",
             employee_number: "5",
             uid: "5",
             basic_work_time: Time.current.change(hour: 8, min: 0, sec: 0),
             designated_work_start_time: Time.current.change(hour: 9, min: 0, sec: 0),
             designated_work_end_time: Time.current.change(hour: 17, min: 0, sec: 0),
             superior: false,
             admin: false,
             password: "password",
             password_confirmation: "password")

