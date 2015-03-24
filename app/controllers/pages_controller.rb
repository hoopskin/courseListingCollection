class PagesController < ApplicationController
  require 'uri'
  require 'net/http'
  require 'nokogiri'

  def home
    
  end

  def refreshCourseListing
    params = {'semester' => '20161Summer 2015                             ',
          'subject' => 'IT  INFORMATION TECHNOLOGY',
          'campus' => '1,2,3,4,5,6,7,9,A,B,C,I,L,M,N,P,Q,R,S,T,W,U,V,X,Y,Z',
          'startTime' => '0600',
          'endTime' => '2359',
          'days' => 'ALL',
          'All' => 'All Sections'}
    @x = Net::HTTP.post_form(URI.parse('http://www3.mnsu.edu/courses/selectform.asp'), params)
    File.open('out.htm', 'w') { |f| f.write @x.body }
    redirect_to :action => results
  end

  def results
    @page = Nokogiri::HTML(open('out.htm'))
    @page.traverse do |x|
      if x.text?
        puts "maybe"
        if x.content.include? "Session"
          puts "changing"
          x.name = "h1"
        end
      end
    end


    @page.css("b").each { |div| 
      if div.content.include? "Session"
        div.name = "h1"
        div.set_attribute("align", "center")
      end 
    }

    @rowSize = @page.css("tr").size
    @curRow = 0

    while @curRow < @rowSize do
      if (@page.css("tr")[@curRow].css("td").size == 1) && (@page.css("tr")[@curRow+1].css("td").size == 12)
        @available = (@page.css("tr")[@curRow+1].css("td")[8].content.to_i - @page.css("tr")[@curRow+1].css("td")[9].content.to_i)
        if @available == 0
          #Red
          @page.css("tr")[@curRow].css("td").first.set_attribute("bgcolor", "red")
        elsif @available.between?(1,10)
          #Yellow
          @page.css("tr")[@curRow].css("td").first.set_attribute("bgcolor", "yellow")
        elsif @available.between?(10,30)
          #Green
          @page.css("tr")[@curRow].css("td").first.set_attribute("bgcolor", "green")
        else
          #Black
          @page.css("tr")[@curRow].css("td").first.set_attribute("bgcolor", "black")
        end
      end
            
      @curRow = @curRow+1
    end

    puts @page.errors
    render :text => @page.to_html, :content_type => 'text/html'
    #render :results
  end
end
