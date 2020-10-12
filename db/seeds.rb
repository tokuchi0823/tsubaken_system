Admin.create!(name: "管理者",
              login_id: "AD-admin",
              password: "password",
              password_confirmation: "password")

puts "CREATE! ADMIN"

Manager.create!(name: "マネージャーA",
                login_id: "MN-mng-a",
                phone: "08011112222",
                email: "manager-a@email.com",
                password: "password",
                password_confirmation: "password")

Manager.create!(name: "マネージャーB",
                login_id: "MN-mng-b",
                phone: "08011112222",
                email: "manager-b@email.com",
                password: "password",
                password_confirmation: "password")

puts "CREATE! MANAGER"

Staff.create!(name: "スタッフA",
              login_id: "ST-stf-a",
              phone: "08011112222",
              email: "staff-a@email.com",
              password: "password",
              password_confirmation: "password")

Staff.create!(name: "スタッフB",
              login_id: "ST-stf-b",
              phone: "08011662222",
              email: "staff-b@email.com",
              password: "password",
              password_confirmation: "password")

puts "CREATE! STAFF"

Supplier.create!(name: "テスト外注先A",
                 kana: "テストガイチュウサキエー",
                 phone_1: "08054545454",
                 email: "testsupplier-a@email.com",
                 zip_code: "5940088",
                 address: "大阪府テスト市")
          
                 Supplier.create!(name: "テスト外注先B",
                 kana: "テストガイチュウサキビー",
                 phone_1: "08054545774",
                 email: "testsupplier-b@email.com",
                 zip_code: "5940188",
                 address: "大阪府テスト市")

puts "CREATE! Supplier"

Industry.create!(name: "塗装関係")
Industry.create!(name: "足場関係")

puts "CREATE! INDUSTRY"

Client.create!(name: "テスト顧客A",
               login_id: "CL-clt-a",
               phone_1: "08011112222",
               phone_2: "08011113333",
               email: "testclient-a@email.com",
               zip_code: "5940088",
               address: "大阪府テスト市",
               password: "password",
               password_confirmation: "password")
              
Client.create!(name: "テスト顧客B",
               login_id: "CL-clt-b",
               phone_1: "08011112222",
               phone_2: "08011113333",
               email: "testclientr-b@email.com",
               zip_code: "5940088",
               address: "大阪府テスト市",
               password: "password",
               password_confirmation: "password")

puts "CREATE! CLIENT"