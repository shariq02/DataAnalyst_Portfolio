demo <- read.csv("demographics_de.csv")

head(demo)
View(demo)

demo2 <- demo[demo$gender == "female",]
View(demo2)

demo3 <- demo[demo$state == "Berlin",]
head(demo3)
