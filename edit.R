control <- trainControl(method = "cv", number = 10, verboseIter = T,
                        
                        summaryFunction = twoClassSummary
)


grid_xgb <- expand.grid(eta = 0.001,
                        
                        max_depth = 10, 
                        
                        nrounds = 2000)


caret_xgb <- train(train, train_target,
                   
                   method = "xgbTree" , trControl = control,
                   
                   metric = "auc" ,
                   
                   tuneGrid = grid_xgb,
                   
                   savePredictions=TRUE, 
                   
                   "min_child_weight" = 20,
                   
                   "subsample" = .7,
                   
                   "colsample_bytree" = .8,
                   
                   "scale_pos_weight" = 1.5
                   
)

##########################################################################################################
#09192015

#This time scaled only the date columns should see what happens when we scale the entire train set

#Tried removing predictors with corelations greater than 0.75 left with oly 400var , 0.78xx CV score

#bad cv scores when all variables are scaled

#Added caret model obj to the model
=======
write_csv(submission, "09182015_1.csv")

########################################################################################################################

start <- Sys.time()

models <- c()

for( i in 1:10) {

rand_num_trees<- sample(500:1000, 1 )

rand_max_depth <- sample(5:15, 1)

rand_learn_rate <- 0.025 * sample(1:10, 1)

rand_min_rows <- sample(1:10, 1)

model_name <- paste0( "GBM_", i,

		      "rand_num_trees",

	              "rand_max_depth",

		      "rand_learn_rate",

		      "rand_min_rows" )

model_gbm <- h2o.gbm( x = feature.names,

		      y = "target",

		      training_frame = training.hex,

	              model_id = model_name,

		      distribution = "binomial",

		      ntrees = rand_num_trees,

		      max_depth = rand_max_depth, 

		      min_rows  = rand_min_rows,

		      learn_rate = rand_learn_rate,

		      nfolds = 5 #add other params by searching (make d model more efficient)
)

models <- c(models, model_gbm)

} 


gbm_time <- start - Sys.time()

#find the best model

best_error <- #tmp

for(i in 1:length(models)) {

err <- h2o.auc(h2o.performance(models[[i]], validation.hex))

if(err < tmp) {

best_error <- err

best_model <- models[[i]]

}

}

#show the best parameters and working model

params <- best_model@allparameters

params$ntrees
params$max_depth
params$min_rows
params$learn_rate

## training set performance metrics

h2o.auc(h2o.performance(best_model, training.hex))

## validation set performance metrics

h2o.auc(h2o.performance(best_model, validation.hex))

#########################################################################################################################################################################

#OUTLIER DETECTION


dl_autoencoder = h2o.deeplearning(x = feature.names , training_frame = training.hex,  model_id = "autoencoders", 

				  autoencoder = T)

anomalies   = h2o.anomaly(object = dl_autoencoder, training.hex)

anomalies.R = as.data.frame(anomalies)

# Plot the reconstruction error and add a line for error in the 90th percentile

quantile  = h2o.quantile(anomalies$Reconstruction.MSE)

threshold = quantile["90%"]

plot(anomalies.R$Reconstruction.MSE)

abline(h=threshold)

#############################################################################################################################

#strategy_1 for NA 

train_char[train_char==-1] = NA

train_char[train_char==""] = NA

train_char[train_char=="[]"] = NA

## sapply(train_numr,  (function to check for atleast four continous 9`s))

#sapply(

train_numr[train_numr %in%  c(999999998, 999999999, -99999, -99999, -99999999, 999999996 ] = NA

########################################################################################################################

#knnImpute high data size

pp_1_test = preProcess(iris_miss_1, method = "knnImpute")

set.seed(1)

test_1_result <- predict(pp_1_test, iris_miss_1)

#bag Impute

preProc <- preProcess(method="bagImpute", training[, 1:4])

training[, 1:4] <- predict(preProc, training[, 1:4])

#considering the number of NA`s should check for median NA impute		

