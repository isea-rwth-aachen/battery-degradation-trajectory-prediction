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

#model structure definition
#input part
InputCap=tf.keras.layers.Input(shape=(cIntInputSeqLen,cIntProcFeatures))
MaskedInputCap=tf.keras.layers.Masking(mask_value=cIntMaskValue)(InputCap)
InputIR=keras.layers.Input(shape=(cIntInputSeqLen,cIntProcFeatures))
MaskedInputIR=tf.keras.layers.Masking(mask_value=cIntMaskValue)(InputIR)
CombInput = keras.layers.Concatenate(axis=-1)([MaskedInputCap, MaskedInputIR])
#encoder part
EncCtext=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(CombInput)
EncCtext=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(EncCtext)
EncCtext=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(EncCtext)
EncCtextOut=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=False))(EncCtext)
CombCtext=tf.keras.layers.RepeatVector(cIntOutputSeqLen)(EncCtextOut)
#decoder part for capacity
Dec1=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(CombCtext)
Dec1=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(Dec1)
Dec1=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(Dec1)
Dec1=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(Dec1)
Dec1=tf.keras.layers.TimeDistributed(tf.keras.layers.Dense(cIntHiddenNode*2, activation="relu",kernel_regularizer=regularizers.l1_l2(l1=1e-5, l2=1e-4)))(Dec1)
Dec1=tf.keras.layers.TimeDistributed(tf.keras.layers.Dense(cIntHiddenNode/2, activation="relu"))(Dec1)
DecOutCap=tf.keras.layers.TimeDistributed(tf.keras.layers.Dense(1, activation="relu"))(Dec1)
#decoder part for IR
Dec2=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(CombCtext)
Dec2=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(Dec2)
Dec2=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(Dec2)
Dec2=tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(cIntHiddenNode,return_sequences=True))(Dec2)
Dec2=tf.keras.layers.TimeDistributed(tf.keras.layers.Dense(cIntHiddenNode*2, activation="relu",kernel_regularizer=regularizers.l1_l2(l1=1e-5, l2=1e-4)))(Dec2)
Dec2=tf.keras.layers.TimeDistributed(tf.keras.layers.Dense(cIntHiddenNode/2, activation="relu"))(Dec2)
DecOutIR=tf.keras.layers.TimeDistributed(tf.keras.layers.Dense(1, activation="relu"))(Dec2)

model=tf.keras.Model(inputs=[InputCap,InputIR],outputs=[DecOutCap,DecOutIR])

#load training data
trCap=pickle.load(open('trCap.p',"rb"))
trIR=pickle.load(open('trIR.p',"rb"))
vaCap=pickle.load(open('vaCap.p',"rb"))
vaIR=pickle.load(open('vaIR.p',"rb"))

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
x0,y0=BuildSeqs(trCap,trIR)
x1,y1=BuildSeqs(vaCap,vaIR)
#set checkpoint path
checkpoint_path0 = "capir/weight0_{epoch:04d}-{loss:.2f}-{val_loss:.2f}.hdf5"
checkpoint_path1 = "capir/weight1_{epoch:04d}-{loss:.2f}-{val_loss:.2f}.hdf5"
checkpoint_path2 = "capir/weight2_{epoch:04d}-{loss:.2f}-{val_loss:.2f}.hdf5"
#define checkpoint and early stopping callback
cp_callback0 = tf.keras.callbacks.ModelCheckpoint(filepath=checkpoint_path0, save_weights_only=True,verbose=1,save_freq='epoch')
cp_callback1 = tf.keras.callbacks.ModelCheckpoint(filepath=checkpoint_path1, save_weights_only=True,verbose=1,save_freq='epoch')
cp_callback2 = tf.keras.callbacks.ModelCheckpoint(filepath=checkpoint_path2, save_weights_only=True,verbose=1,save_freq='epoch')
callback2 = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=32,restore_best_weights=True)
#train model for stage 0
model.compile(optimizer=tf.keras.optimizers.Adam(lr=1e-4),loss=CustomLoss.MaskedMAE,metrics=[],loss_weights=([1.0,0.0]))
model.fit(x0,y0,batch_size=384,epochs=450,verbose=2,validation_data=(x1,y1),shuffle=True,callbacks=[cp_callback0,callback2])
model.save("2CapIR2_stg0.h5")
#freeze weights for stage 1
for idx in range(len(model.layers)):
    model.layers[idx].trainable=False
model.layers[11].trainable=True
model.layers[13].trainable=True
model.layers[15].trainable=True
model.layers[17].trainable=True
model.layers[19].trainable=True
model.layers[21].trainable=True
model.layers[23].trainable=True
#train model for stage 1
#sometimes need load checkpoint because the local best solution may not be the best solution for remaining stages.
#model.load_weights('capir/weight0_best.hdf5')
model.compile(optimizer=tf.keras.optimizers.Adam(lr=1e-4),loss=CustomLoss.MaskedMAE,metrics=[],loss_weights=([0.0,1.0]))
model.fit(x0,y0,batch_size=384,epochs=450,verbose=2,validation_data=(x1,y1),shuffle=True,callbacks=[cp_callback1,callback2])
model.save("2CapIR2_stg1.h5")
#defreeze all weights for stage 2
for idx in range(len(model.layers)):
    model.layers[idx ].trainable=True
#train model for stage 2
#model.load_weights('capir/weight1_best.hdf5')
model.compile(optimizer=tf.keras.optimizers.Adam(lr=1e-5),loss=CustomLoss.MaskedMAE,metrics=[],loss_weights=([1.0,1.0]))
#model.load_weights('capir/weight2_best.hdf5')
model.fit(x0,y0,batch_size=512,epochs=300,verbose=1,validation_data=(x1,y1),shuffle=True,callbacks=[cp_callback2,callback2])

#save model
model.save("2CapIR2.h5")
tf.keras.utils.plot_model(model,"2CapIR2.png",show_shapes=True,expand_nested=True)
