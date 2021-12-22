import numpy as np
import tensorflow as tf
from tensorflow.keras.layers import *
from tensorflow.keras.models import Model
from tensorflow.keras.regularizers import *
from tensorflow.keras import Input
from tensorflow.keras.optimizers import Adadelta,Adam
from tensorflow.keras import regularizers
import tensorflow.keras as keras
import tensorflow.keras.backend as kb
import pickle

#define model parameters
tf.keras.backend.set_epsilon(1e-9)
cIntInputSeqLen=384
cIntOutputSeqLen=128
cIntProcFeatures=1
cIntHiddenNode=64
cIntBatchSize=384
cIntEpoch=450
lr=1e-4
cIntMaskValue=0

#define custom loss function
class CustomLoss:
    @staticmethod
    def RMSE(y_true, y_pred):
        return kb.sqrt(tf.keras.losses.mean_squared_error(y_true, y_pred))
    @staticmethod
    def MaskedRMSE(y_true,y_pred):
        isMask = kb.equal(y_true, 0)
        isMask = kb.all(isMask, axis=-1)
        isMask = kb.cast(isMask, dtype=kb.floatx())
        isMask = 1 - isMask
        isMask = kb.reshape(isMask,tf.shape(y_true))
        masked_squared_error = kb.square(isMask * (y_true - y_pred))
        masked_mse = kb.sum(masked_squared_error, axis=-1) / (kb.sum(isMask, axis=-1)+kb.epsilon())
        return kb.sqrt(masked_mse)
    @staticmethod
    def MaskedMSE(y_true,y_pred):
        isMask = kb.equal(y_true, 0)
        isMask = kb.all(isMask, axis=-1)
        isMask = kb.cast(isMask, dtype=kb.floatx())
        isMask = 1 - isMask
        isMask = kb.reshape(isMask,tf.shape(y_true))
        masked_squared_error = kb.square(isMask * (y_true - y_pred))
        masked_mse = kb.sum(masked_squared_error, axis=-1) / (kb.sum(isMask, axis=-1)+kb.epsilon())
        return masked_mse
    @staticmethod
    def MaskedMAE(y_true,y_pred):
        isMask = kb.equal(y_true, 0)
        isMask = kb.all(isMask, axis=-1)
        isMask = kb.cast(isMask, dtype=kb.floatx())
        isMask = 1 - isMask
        isMask = kb.reshape(isMask,tf.shape(y_true))
        masked_AE = kb.abs(isMask * (y_true - y_pred))
        masked_mae = kb.sum(masked_AE, axis=-1)/ (kb.sum(isMask, axis=-1)+kb.epsilon())
        return masked_mae
    #numpy function wrapper
    @staticmethod
    @tf.function
    def MaskedMAPE(y_true,y_pred):
        return tf.py_function(CustomLoss.numpyMaskedMAPE ,(y_true, y_pred), tf.double)
    @staticmethod
    def numpyMaskedMAPE(y_true,y_pred):
        MapeLst=list()
        for elm_t,elm_p in zip(y_true,y_pred):
            y_t=elm_t[0:np.count_nonzero(elm_t),:]
            y_p=elm_p[0:np.count_nonzero(elm_t),:]
            MapeLst.append(np.mean(((np.abs(y_t - y_p)+1e-10) / y_t)) * 100)
        return np.array(MapeLst,dtype=np.float)

#define sequential model for capacity
model = keras.Sequential()
model.add(tf.keras.layers.Masking(mask_value=cIntMaskValue))
model.add(tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True)))
model.add(tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True)))
model.add(tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True)))
model.add(tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=False)))
model.add(tf.keras.layers.RepeatVector(cIntOutputSeqLen))
model.add(tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True)))
model.add(tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True)))
model.add(tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True)))
model.add(tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True)))
model.add(tf.keras.layers.TimeDistributed(tf.keras.layers.Dense(cIntHiddenNode*2, activation="relu")))
model.add(tf.keras.layers.TimeDistributed(tf.keras.layers.Dense(cIntHiddenNode/4, activation="relu")))
model.add(tf.keras.layers.TimeDistributed(tf.keras.layers.Dense(cIntProcFeatures, activation="linear")))


#load training data
trCap=pickle.load(open('trCap.p',"rb"))
trIR=pickle.load(open('trIR.p',"rb"))
teCap=pickle.load(open('teCap.p',"rb"))
teIR=pickle.load(open('teIR.p',"rb"))

#function to build training data
def BuildSeqs(Cap,IR):
    #declare list for input capacity and input IR as ls1 and ls2
    #declare list for output capacity and output IR as ls3 and ls4
    ls1,ls2,ls3,ls4=list(),list(),list(),list()
    for SelectCap,SelectIR in zip(Cap,IR):
        if(len(SelectIR)<len(SelectCap)):
            SelectCap=SelectCap[0:len(SelectIR)]
        elif(len(SelectCap)<len(SelectIR)):
            SelectIR=SelectIR[0:len(SelectCap)]
        SelectIR=SelectIR/0.04*100
        SelectCap=SelectCap/1.85*100
        x_lst=[]
        x_lst2=[]
        y_lst=[]
        y_lst2=[]
        for i in range(20,len(SelectIR)-20,1):
            splitPos = i
            inputSeq=SelectCap[0:splitPos]
            x_lst.append(inputSeq.reshape(-1,1))
            inputSeq2=SelectIR[0:splitPos]
            x_lst2.append(inputSeq2.reshape(-1,1))
            OutputSeq=SelectCap[splitPos-1::4].tolist()
            y_lst.append(OutputSeq)
            OutputSeq2=SelectIR[splitPos-1::4].tolist()
            y_lst2.append(OutputSeq2)
        #zero padding
        Proc_X=tf.keras.preprocessing.sequence.pad_sequences(x_lst,maxlen=cIntInputSeqLen,dtype='float64',padding='pre',value=0)
        Proc_X2=tf.keras.preprocessing.sequence.pad_sequences(x_lst2,maxlen=cIntInputSeqLen,dtype='float64',padding='pre',value=0)
        Proc_Y1=tf.keras.preprocessing.sequence.pad_sequences(y_lst,maxlen=cIntOutputSeqLen,dtype='float64',padding='post',value=0)
        Proc_Y2=tf.keras.preprocessing.sequence.pad_sequences(y_lst2,maxlen=cIntOutputSeqLen,dtype='float64',padding='post',value=0)
        Proc_X=Proc_X.reshape(-1,cIntInputSeqLen,cIntProcFeatures)
        Proc_X2=Proc_X2.reshape(-1,cIntInputSeqLen,cIntProcFeatures)
        Proc_Y1=Proc_Y1.reshape(-1,cIntOutputSeqLen,cIntProcFeatures)
        Proc_Y2=Proc_Y2.reshape(-1,cIntOutputSeqLen,cIntProcFeatures)
        for a,b,c,d in zip(Proc_X,Proc_X2,Proc_Y1,Proc_Y2):
            ls1.append(a)
            ls2.append(b)
            ls3.append(c)
            ls4.append(d)
    
    return (np.array(ls1,dtype=np.float),np.array(ls2,dtype=np.float)),(np.array(ls3,dtype=np.float),np.array(ls4,dtype=np.float))
#generate training data
#only use capacity data
(x0,_),(y0,_)=BuildSeqs(trCap,trIR)
(x1,_),(y1,_)=BuildSeqs(teCap,teIR)
#set checkpoint path
checkpoint_path = "caponly/weight_{epoch:04d}-{val_loss:.2f}.hdf5"
#define checkpoint and early stopping callback
callback2 = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=32,restore_best_weights=True)
cp_callback = tf.keras.callbacks.ModelCheckpoint(filepath=checkpoint_path, save_weights_only=True,verbose=2,save_freq='epoch')
#start training
model.compile(optimizer=tf.keras.optimizers.Adam(lr=lr),loss=CustomLoss.MaskedMAE,metrics=[CustomLoss.MaskedMAPE,CustomLoss.MaskedRMSE])
#verbose should be 1 if you want to see the training progress
model.fit(x0,y0,batch_size=cIntBatchSize,epochs=cIntEpoch,verbose=2,validation_data=(x1,y1),shuffle=True,callbacks=[cp_callback,callback2])
#save model
model.save("CapOnly.h5")