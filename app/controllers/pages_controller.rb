class PagesController < ApplicationController
  require 'uri'
  require 'net/http'
  require 'nokogiri'
  require 'csv'

  def home
    
  end

  def refreshCourseListing
    #params = {'semester' => '20161Summer 2015                             ',
    #      'subject' => 'IT  INFORMATION TECHNOLOGY',
    #      'campus' => '1,2,3,4,5,6,7,9,A,B,C,I,L,M,N,P,Q,R,S,T,W,U,V,X,Y,Z',
    #      'startTime' => '0600',
    #      'endTime' => '2359',
    #      'days' => 'ALL',
    #      'All' => 'All Sections'}
    #@x = Net::HTTP.post_form(URI.parse('http://www3.mnsu.edu/courses/selectform.asp'), params)
    #File.open('out.htm', 'w') { |f| f.write @x.body }

    Course.delete_all

    @page = Nokogiri::HTML(open('out.htm'))
    
    @rowSize = @page.css('table')[1].css('tr').size
    @curRowIdx = 0

    while @curRowIdx < @rowSize do
      #Get Current Row
      @curRow = @page.css('table')[1].css('tr')[@curRowIdx]
      @increment = 1
      #Check if it's a course header row (e.g. 'IT 100 - Title (X Cred)')
      if (@curRow.css("td").size == 1) && (@page.css('table')[1].css('tr')[@curRowIdx+1].css("td").size == 12)
        
        while (@curRowIdx+@increment < @rowSize) and (@page.css('table')[1].css('tr')[@curRowIdx+@increment].css("td").size == 12)
          #Collect Info
          #Get Data Row
          @dataRow = @page.css('table')[1].css('tr')[@curRowIdx+@increment]

          newCourse = Course.new

          #Course College
          newCourse.college = @curRow.css('td').css('font')[0].css('b')[0].content.to_s.strip!
  
          #Course Number
          if @curRow.css('td').css('font')[0].css('b')[1].content.to_s.strip! == nil
            newCourse.number = @curRow.css('td').css('font')[0].css('b')[1].content.to_s
          else
            newCourse.number = @curRow.css('td').css('font')[0].css('b')[1].content.to_s.strip!
          end

          if newCourse.number == '550'
            puts 'hey there'
          end
  
          #Course Title
          newCourse.title = @curRow.css('td').css('font')[1].css('b')[0].content.to_s.strip!
  
          #Credits (Can't use trim because nbsp is a character, this gets the digit)
          newCourse.credits = @curRow.css('td').css('font')[1].css('b')[1].content.to_s[3]
  
          #Course ID
          newCourse.courseId = @dataRow.css('td')[0].content
  
          #Sect
          newCourse.sect = @dataRow.css('td')[1].content[0,2]
  
          #Grade Meth
          newCourse.gradeMeth = @dataRow.css('td')[2].content
  
          #Days
          newCourse.days = @dataRow.css('td')[3].content.strip!
  
          #Time
          newCourse.time = @dataRow.css('td')[4].content.strip!
  
          #Dates
          newCourse.dates = @dataRow.css('td')[5].content
  
          #Bldg/Room
          newCourse.bldg = @dataRow.css('td')[6].content.strip!
  
          #Instructor
          newCourse.instructor = @dataRow.css('td')[7].content.strip!
  
          #Size
          newCourse.size = @dataRow.css('td')[8].content
  
          #Enrl
          newCourse.enrl = @dataRow.css('td')[9].content
  
          #Status
          newCourse.status = @dataRow.css('td')[10].content
  
          #Add'l Notes
          newCourse.addlNotes = @dataRow.css('td')[11].content

          #TODO: Semester
          #newCourse.semester = 
          #TODO: Session
          #newCourse.session =

          #If next row is secondary data
          if (@curRowIdx+@increment+1 < @rowSize) and (@page.css('table')[1].css('tr')[@curRowIdx+@increment+1].css("td").size == 7)
            @dataRow2 = @page.css('table')[1].css('tr')[@curRowIdx+@increment+1]

            #Days2
            newCourse.days2 = @dataRow2.css("td")[1].content.strip!
            #Time2
            newCourse.time2 = @dataRow2.css("td")[2].content.strip!
            #Dates2
            newCourse.dates2 = @dataRow2.css("td")[3].content
            #Bldg/Room2
            newCourse.bldg2 = @dataRow2.css("td")[4].css("a").css("b")[0].content.strip!
            #Instructor2
            newCourse.instructor2 = @dataRow2.css("td")[5].content.strip!

            @increment = @increment + 2
          else
            @increment = @increment + 1
          end
        end

        newCourse.save
      end

      @curRowIdx = @curRowIdx + @increment
      #@curRowIdx = @curRowIdx + 1
    end

    puts "prereqs and offered time"

    csvFile = CSV.read('itPrereqs.csv')

    #For each course
    Course.all.each do |curCourse|
      csvFile.each do |row|
        #Go through each 0th cell and find the match
        if row[0].eql?(curCourse.college+curCourse.number)
          #Get the Prereqs
          curCourse.prereqs = row[1]

          #Get the Offered value
          curCourse.offered = row[2]

          #Get the historical enrollment value

          curCourse.save
          break
        end
      end
    end

    #Prereqs?
    #newCourse.prereqs =

    #Offered?
    #newCourse.offered =

    puts "finally finished"
    redirect_to :action => "printResults"
  end

  def printResults
    puts 'hi'
    render :printResults
  end
end
