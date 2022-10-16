#importing our libraries so we don't get any errors
library(Rcpp)
library(Ropj)
library(ggplot2)
library(shiny)

#setting up the ui to do all the flashy stuff
ui <- fluidPage(
  titlePanel("Fluorolog Data Compiler v1.7.3"),
  sidebarLayout(
    sidebarPanel(
      numericInput("num2", label= h4("Emission Peak"),value=509),
      numericInput("num", label = h4("Measurements per construct"), value = 27),
      h4("Construct names"),
      textInput("text", label = h5("please put commas between names"), value = "35S,Buffer,SARE,JASE,JERE,ERE,PR1,SBox,NPR1,JAR"),
    ),
    mainPanel(
      plotOutput(outputId = "distPlot"),
      h3("Please fill in all information before hitting 'see data'"),
      actionButton("seeData","see data")
    )
  )
)

#setting up the server to do all the fun stuff
server<-function(input, output){
  
  # lets you choose the working directory (pick the folder where your files are)
  setwd(choose.dir())
  
  # brings in the path and name of the opj file we want to open
  opjfiles<-list.files(path=getwd(),pattern="*.OPJ",full.names=F,recursive=F)
  if (is.na(opjfiles)){
    opjfiles<-list.files(path=getwd(),pattern="*.opj",full.names=F,recursive=F)
  }

  # reads in our opj file
  expopj<-read.opj(paste(getwd(),"/",opjfiles[1],sep=""), encoding="latin1",tree=F)
  
  
  # does the calculations and such, but only if we hit the see data button
  graphReactive<-eventReactive( input$seeData, {
    
    #getting the number of samples from the user
    sample_no<-input$num
    
    #getting the list of names from the user
    plantlist<-strsplit(input$text,split=",",fixed=T)
    # the names come out in a nested list so we have to un-nest them here to make them usable
    plantlist<-plantlist[[1]]
    
    if(sample_no*length(plantlist)>length(expopj)){
      while (sample_no*length(plantlist)>length(expopj)){
        sample_no <- sample_no-1
      }
    }
    
    # some variables to set up to make the for loop run more smoothly
    first<-T
    alldf<-data.frame()
    exp_no<-1
    
    #This loop takes all the data from the file and puts however many measurements you have into one file then converts that into a .csv
    #there is almost certainly a better way to do this but i am too tired to see it
    for(n in 1:length(expopj)){
      
      #taking the data from our opj file and removing any NaN values then making a new data frame of that
      df2<-na.omit(expopj[[n]]$Data)
      
      #renaming the columns because its named weird in the opj file
      colnames(df2)<-c("Wavelength","S1")
      
      #for the first measurement of the list we do something special so we do not have errors later
      if (first==T){
        #we just rename it to df1
        df1<-df2
        #nothing else is first so we toggle that boolean
        first<-F
      }
      
      #once we have all the measurements parsed out then we combine all of them together and export it as a csv for every plant
      else if(n%%sample_no==0){
        #combine all our data for this sample together one last time
        df1<-rbind(df1,df2)
        #making a data frame of all our data
        alldf<-rbind(alldf,df1)
        #making the file for each construct
        write.csv(df1,paste(getwd(),"/",plantlist[exp_no],".csv",sep=""),row.names=F)
        #increment our variable so we are indexing the right file
        # theres probably a better way to do this fix later
        exp_no<-exp_no+1
        #now that we are done we can re-toggle the first boolean
        first<-T
      }
      
      else{
        #if it is not the first or the last then we just add it to the list for that construct
        df1<-rbind(df1,df2)
      }
    }
    
    #setting up another vector
    plantnames<-c()
    
    #here we make a list so we can sort all the values by the name of the construct
    for (i in 1:length(plantlist)){
      n <- 1
      while(n<=sample_no*length(df2$Wavelength)){
        plantnames<-append(plantnames,plantlist[i])
        n <- n+1
      }
    }
    #here we add extra names to the list if the person did not make things even steven
    extras<-1
    while(length(plantnames)<length(alldf)){
      n<-1
      while(n<=sample_no*length(df2$Wavelength)){
        plantnames<-append(plantnames,paste("extra",extras))
        n <- n+1
      }
      extras<-extras+1
    }
    alldf$Names<-plantnames
    
    #here we make a list of all values from the plants at the specified wavelength
    lst1<-alldf$S1[alldf$Wavelength==input$num2]
    plantlist2<-alldf$Names[alldf$Wavelength==input$num2]
    write.csv(alldf,paste(getwd(),"/","Allplants",".csv",sep=""),row.names=F)
    
    #here we are making a new data frame to compute the average and standard deviation easily
    datapoints<-data.frame(Sample=plantlist2,Measurement=lst1)
    #here we are making a new data frame to store that information easily
    finaldf<-data.frame(Sample=plantlist,Average=1:length(plantlist),sd=1:length(plantlist))
    
    #this for loop calculates the average and standard deviation for each of our plants
    for (i in 1:length(plantlist)){
      
      #here we are assigning all measurements that fit our sample to a variable
      emissionPeaks<-datapoints$Measurement[datapoints$Sample==plantlist[i]]
      
      #here we calculate and assign the average
      finaldf$Average[finaldf$Sample==plantlist[i]]<-mean(emissionPeaks)
      #here we calculate and assign the standard deviation
      finaldf$sd[finaldf$Sample==plantlist[i]]<-sd(emissionPeaks)
    }
    
    #here we assign the values we want on our bar plot
    ggplot(data=finaldf,aes(x=Sample,y=Average))+
      #here we let ggplot know we want a barplot
      geom_bar(stat="identity")+
      #here we set up how we want our error bars to look
      geom_errorbar(aes(ymin=Average-sd, ymax=Average+sd),width=.2)
    
  })
  
  #here we finally grab our plot and display it
  output$distPlot <- renderPlot({
    #calling the function to grab our plot
    graphReactive()
  })
}

#launcing our shiny app
shinyApp(ui=ui,server=server)
