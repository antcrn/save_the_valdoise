require 'bundler'
Bundler.require

class Scrapper
    
def initialize
    perform
end

def scrap
        doc = Nokogiri::HTML(URI.open("http://annuaire-des-mairies.com/val-d-oise.html"))
        tableau_mairies = []
        tableau_liens = []
        tableau_mails = []
        doc.css('td > p > a.lientxt').each do |lien|
          tableau_mairies.push(lien.text)
          link_name = "http://annuaire-des-mairies.com/" + lien[@class="href"][1, 10000]
          doc2 = Nokogiri::HTML(URI.open(link_name))
          doc2.css('body > div > main > section:nth-child(2) > div > table > tbody > tr:nth-child(4) > td:nth-child(2)').each do |mail|
            tableau_mails.push(mail.text)
          end
        end
        hash = Hash[]
        hash = tableau_mairies.zip(tableau_mails).map {|k, v| {k => v}}
        return hash
      
end

def save_as_json(x)
    my_json= JSON.generate(x)
    file= File.open("db/emails.json", "w")
    file.puts(my_json)
    file.close
end   

def save_as_csv(x)
    headers=["Commune","Email"]
    CSV.open("db/email.csv", "a+") do |csv|
        csv << headers
        x.each do |h|
           h.each do |k,v|
             csv << [k,v]
            end
        end
    end
end   
  
def perform
    data=scrap
    save_as_json(data)
    puts "JSON generé"
    save_as_csv(data)
    puts "CSV generé"
end
end