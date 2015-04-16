---
title: "Referral Network Preliminary Analysis of Health System Navigator"
author: "Ziwen Yu"
---

## Executive summary
This document records preliminary analysis on the network data of health system navigation. The data used here is the physician referral in a year (2013~2014).
The network in selected zip code area, **46032**, is firstly visualized geographically. Given the referral number is incredibly large, the further analysis is then focused on avoiding the bias brought by the number magnitude. 

### 1. Programming environment setting up
```{r Load Libraries and data,warning=FALSE,results='hide',message=FALSE}
#load libraries
Libs=c("sna", "ggplot2", "Hmisc", "reshape2",'ggmap','data.table','RODBC','scales','hexbin')
lapply(Libs,library,character.only = TRUE)
#Working directory
setwd('V:\\PRECISION\\Health Systems Navigator\\CMS\\R Code for Data loading\\')
#data for network plotting zip=46032
load('46032data.RData')
#data for referral number analysis state=Indiana
load('State_Net.RData')

# Plot theme
Plot_Theme=   theme_bw()+
              theme(plot.title = element_text(size = 14)
                    ,axis.title.x = element_text(size=12)
                    ,axis.title.y = element_text(size=12)
                    ,axis.text.x = element_text(size=12)
                    ,axis.text.y = element_text(size=12)
                    )
```

### 2. Visualizing network
Before this plotting, a view has been created in SQL2 server to get the name and address of each provider. The Google map API was used to get the geographical location of each provider by their address. The following code displays the geographic layout of providers and their referral network within the area of zip code **46032**. The flow direction of each referral relationship is indicated by the color and size gradient. Log10 of the referral number is used to size the flow, given its highly right-skewed distribution which is shown in the next section. 
```{r Plot network,warning=FALSE,fig.width=7, fig.height=7,fig.show='hold'}
ggmap(Zip5Map)+      
      geom_path(data=allEdges,aes(x = x, y = y, group = Group,  # Edges with gradient
                                  colour = Sequence, size = log10(Size)),alpha=0.3)+
      scale_colour_gradient( guide = "none")+
      scale_size(range = c(1/10, 2), guide = "none")  +
      geom_point(data=PltNode,aes(x=Long,y=Lat,label=Prescriber)
                 ,size=5,fill='orange',color='black',pch=21,alpha=0.3)+
      theme(axis.line=element_blank(),axis.text.x=element_blank(),
            axis.text.y=element_blank(),axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank())
```


### 3. Analyzing referral numbers
The highly skewed referral number distribution (plotted below) could impair the further network analysis by affecting the weight of edges in the network. The distribution of total outgoing referral numbers of all providers in **Indiana** is plotted below. Providers are categorized into two types, "**1**" (prescribers), "**2**"(organizations, such as hospitals).

```{r Referral distribution,fig.width=7, fig.height=3,fig.show='hold'}
PlotDt=State_Ref_Sum #Get data for plotting
ggplot(data=PlotDt)+
      geom_histogram(aes(From_RefTot),binwidth=50000)+
      Plot_Theme
```
The distribution has a long tail on right which contains some extreme large numbers. In order to obtain a clear vision of the distribution, the x axis is converted into log10 scale and the percentiles are also plotted. The percentiles of outgoing, intake and total referrals are also provided. 

```{r results='hold',warning=FALSE,message=FALSE,fig.width=7, fig.height=3,fig.show='hold'}
PlotDt=State_Ref_Sum #Get data for plotting
Pctiles=data.frame(sapply(PlotDt[,c('From_RefTot','ToRefTot','TotalRef'),with=F],
                          quantile,
                          probs= c(0.2,0.4,0.6,0.8,0.9,0.95,0.99,1),
                          na.rm=T
                          )
                   )      #Get the percentiles of Referral out
Pctiles$lab=row.names(Pctiles)

ggplot(data=PlotDt)+
      geom_histogram(aes(From_RefTot))+
      geom_vline(xintercept = Pctiles$From_RefTot,color='red')+
      geom_text(data=Pctiles,aes(x=From_RefTot,y=0,label=lab),size=3,color='red')+
      scale_x_log10(breaks=10^(seq(0,9)))+
      Plot_Theme
Pctiles
```
The plots tell us that the referral number is generally too large to make any sense (e.g. some prescribers have to refer one patient per minute to match these numbers).

### 4.Modeling referral and network degrees
The next step is to explore the relationship between the referral number and the heaviness of the connections (degrees in the network). Degree refers to the connections that is from or pointing to a certain node (provider here).  Three linear regressions are performed: intake referral analysis, outgoing analysis, general referral analysis.  
All analysis is performed on the log10 scale of both referral number and degree. Only type **2** providers (Organizations) are considered in this step since their degrees are generally higher.



* __Modeling intake referral vs. in degree__           
In degree refers to the number of connections pointing to the provider. A linear regression is conducted to model referral numbers and degrees pointing to a provider.
```{r Check relationship between degree and referral-in,fig.width=7, fig.height=5,fig.show='hold'}
EntityType=c(2) # Organization providers
PlotDt=subset(State_Ref_Sum,Entity_Type_Code %in% EntityType)  #Get data for plotting
# Received referral vs in degree
ggplot(data=PlotDt,aes(x=log10(InDeg),y=log10(ToRefTot)))+
      stat_binhex(na.rm=T)+
      labs(title='Received Referral vs In Degree',
           y='log Received Referrals',
           x='log In Degree')+
      stat_smooth(method='lm',color='red',size=1,se=F,na.rm=T)+
      Plot_Theme

lmMod=lm(I(log10(ToRefTot))~I(log10(InDeg)),data=PlotDt) #Regression model 
summary(lmMod)$adj.r.squared 
```

For intake referrals, the linear regression model represents **`r percent(summary(lmMod)$adj.r.squared)`** variance of the observation model.

* __Modeling outgoing referral vs. out degree__         
Out degree referres to the number of connections sourcing from the provider. A linear regression is conducted to model referral numbers and degrees going out from a provider.
```{r Check relationship between degree and referral-out,fig.width=7, fig.height=5,fig.show='hold'}
# Outgoing referral vs out degree
ggplot(data=PlotDt,aes(x=log10(OutDeg),y=log10(From_RefTot)))+
      stat_binhex(na.rm=T)+
      labs(title='Outgoing Referral vs Out Degree',
           y='log Outgoing Referrals',
           x='log Out Degree')+
      stat_smooth(method='lm',color='red',size=1,se=F,na.rm=T)+
      Plot_Theme

lmMod=lm(I(log10(From_RefTot))~I(log10(OutDeg)),data=PlotDt) #Regression model 
summary(lmMod)$adj.r.squared 
```

For outoing referral, the linear regression model represents **`r percent(summary(lmMod)$adj.r.squared)`** variance of the observation model.

* __Modeling total referral vs. total degree__        
In degree and out degree are combined here. A linear regression is conducted to model total referral numbers and total degrees from and to a provider.
```{r Check relationship between degree and referral-total,fig.width=7, fig.height=5,fig.show='hold'}
# Total referral vs total degree
ggplot(data=PlotDt,aes(x=log10(Degree),y=log10(TotalRef)))+
      stat_binhex(na.rm=T)+
      labs(title='Total Referral vs Total Degree',
           y='log Total Referrals',
           x='log Total Degree')+
      stat_smooth(method='lm',color='red',size=1,se=F,na.rm=T)+
      Plot_Theme

lmMod=lm(I(log10(TotalRef))~I(log10(Degree)),data=PlotDt) #Regression model 
summary(lmMod)$adj.r.squared 
```

For total referral, the linear regression model represents **`r percent(summary(lmMod)$adj.r.squared)`** variance of the observation model.

***INDICATION***: Since the linear regression could interpret the relationship between degree and referrals with over 80% variance, further network analysis could based on connection degree only instead of putting the huge referral number into the calculation.
