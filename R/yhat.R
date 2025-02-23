#' Wrap Various Predict Functions
#'
#' This function is a wrapper over various predict functions for different models and differnt model structures.
#' The wrapper returns a single numeric score for each new observation.
#' To do this it uses different extraction techniques for models from different classes,
#' like for classification random forest is forces the output to be probabilities
#' not classes itself.
#'
#' Currently supported packages are:
#' \itemize{
#' \item class `cv.glmnet` and `glmnet` - models created with `glmnet` package
#' \item class `glm` - generalized linear models
#' \item class `model_fit` - models created with `parsnip` package
#' \item class `lm` - linear models created with `stats::lm`
#' \item class `ranger` - models created with `ranger` package
#' \item class `randomForest` - random forest models created with `randomForest` package
#' \item class `svm` - support vector machines models created with the `e1071` package
#' \item class `train` - models created with `caret` package
#' \item class `gbm` - models created with `gbm` package
#' }
#'
#' @param X.model object - a model to be explained
#' @param newdata data.frame or matrix - observations for prediction
#' @param ... other parameters that will be passed to the predict function
#'
#' @return An numeric matrix of predictions
#'
#' @rdname yhat
#' @export
yhat <- function(X.model, newdata, ...)
  UseMethod("yhat")

#' @rdname yhat
#' @export
yhat.lm <- function(X.model, newdata, ...) {
  predict(X.model, newdata, ...)
}

#' @rdname yhat
#' @export
yhat.randomForest <- function(X.model, newdata, ...) {
  if (X.model$type == "classification") {
    pred <- predict(X.model, newdata, type = "prob", ...)
    if (ncol(pred) == 2) { # binary classification
      pred <- pred[,2]
    }
  } else {
    pred <- predict(X.model, newdata, ...)
  }
  pred
}

#' @rdname yhat
#' @export
yhat.svm <- function(X.model, newdata, ...) {
  if (X.model$type == 0) {
    pred <- attr(predict(X.model, newdata = newdata, probability = TRUE), "probabilities")
    if (ncol(pred) == 2) { # binary classification
      pred <- pred[,2]
    }
  } else {
    pred <- predict(X.model, newdata, ...)
  }
  pred
}

#' @rdname yhat
#' @export
yhat.gbm <- function(X.model, newdata, ...) {
  n.trees <- X.model$n.trees
  if (X.model$distribution == "bernoulli") {
    response <- predict(X.model, newdata = newdata, n.trees = n.trees, type = "response")
  } else {
    response <- predict(X.model, newdata = newdata, n.trees = n.trees)
  }
  response
}


#' @rdname yhat
#' @export
yhat.glm <- function(X.model, newdata, ...) {
  predict(X.model, newdata, type = "response")
}

#' @rdname yhat
#' @export
yhat.cv.glmnet <- function(X.model, newdata, ...) {
  predict(X.model, newdata, type = "response")
}

#' @rdname yhat
#' @export
yhat.glmnet <- function(X.model, newdata, ...) {
  predict(X.model, newdata, type = "response")
}

#' @rdname yhat
#' @export
yhat.ranger <- function(X.model, newdata, ...) {
  if (X.model$treetype == "Regression") {
    pred <- predict(X.model, newdata, ...)$predictions
  } else {
    # please note, that probability=TRUE should be set during training
    pred <- predict(X.model, newdata, ..., probability = TRUE)$predictions
    if (ncol(pred) == 2) { # binary classification
      pred <- pred[,2]
    }
  }
  pred
}

#' @rdname yhat
#' @export
yhat.model_fit <- function(X.model, newdata, ...) {
  if (X.model$spec$mode == "classification") {
    response <- as.data.frame(predict(X.model, newdata, type = "prob"))[,2]
  }
  if (X.model$spec$mode == "regression") {
    pred <- predict(X.model, newdata)
    response <- pred$.pred
  }
  response
}

#' @rdname yhat
#' @export
yhat.train <- function(X.model, newdata, ...) {
  if (X.model$modelType == "Classification") {
    response <- predict(X.model, newdata = newdata, type = "prob")[,2]
  }
  if (X.model$modelType == "Regression") {
    response <- predict(X.model, newdata = newdata)

  }
  response
}


#' @rdname yhat
#' @export
yhat.default <- function(X.model, newdata, ...) {
  as.numeric(predict(X.model, newdata, ...))
}




# #' @rdname yhat
# #' @export
# yhat.catboost.Model <- function(X.model, newdata, ...) {
#   newdata_pool <- catboost::catboost.load_pool(newdata)
#   catboost::catboost.predict(X.model, newdata_pool)
# }
