# -*- coding: utf-8 -*-
"""
Created on Fri Oct 30 17:03:58 2015

@author: Juanma

This script test network resilience removing animal species and measuring
two outocomes: fraction of survivinga vegetal species (dunnemethod) and
fraction of surviving Giant Component (juanmamethod)

"""

import glob
import copy as cp
import numpy as np
import scipy as sp
import networkx as nx
from networkx.algorithms import bipartite
import matplotlib as mpl
import matplotlib.pyplot as plt
from pylab import *
#%matplotlib inline

global NNa, nrows, ncols

dir_results = "results/"

def gen_file_out(fileroot,strf,suffix):
    fileout="results/"+strf+"/"+fileroot+suffix
    print(fileout.replace("../data",""))
    return fileout.replace("../data","")

def read_file_csv(filename):
    archivo = open(filename,'r')
    lista = archivo.read()
    listas = lista.splitlines()
    Lista = [line.split(',') for line in listas]

    Lista.pop(0)  #name of columns
    
    M = np.array([])
    if Lista[-1] == '':
        Lista.pop(-1)
    for line in Lista:
        lista0 = [p for p in line]
        lista0.pop(0)
        lista1 = np.array(lista0)
        R = np.array(lista1, dtype=int)
        RR = np.array((R))
        size_r = RR.size
        M = np.concatenate((M,RR),axis=0)
    size_tot = M.shape
    M.resize((int(size_tot[0]/size_r),size_r))
    print(M)
    return(M)

# Create nx.Graph bipartite (animal - plant)
def M_graph(M):
    G = nx.Graph()
    (Na,Np) = shape(M)
    NNa=offset_plants  #ID for plant = column number + offset_plants
    for i in range(Na):
        animal = i
        G.add_node(animal,bipartite=1)
        
        for j in range(Np):
            plant = j + NNa
            G.add_node(plant,bipartite=0)
            
            if M[i][j]:
                G.add_edge(animal,plant)

    for node in G:
        if node < offset_plants:
            G.node[node]['deg']=int(np.sum(M[node,:]))
            
        else:
            nod = node -offset_plants
            G.node[node]['deg']=int(np.sum(M[:,nod]))
                
    return(G)
    

def K_core_graph(R_graph):    
    Kcore=nx.core_number(R_graph)
    return(Kcore)
    
#Obtain  K_shell_animal & K_shell_plant    
def K_shell(Kcore, nrows, ncols):
    ks_max=int(np.max(list(Kcore.values())))
    Na = nrows
    Np = ncols
    NNa = offset_plants
    K_shell_a={}
    K_shell_p={}
    
    for ks in range(1,ks_max+1,1):
        shell_a=[]
        shell_p=[]
        for l in range(Na):
            if Kcore[l] == ks:
                shell_a.append(l)
        K_shell_a[ks]=shell_a
        for m in range(NNa,NNa+Np,1):
            if Kcore[m] == ks:
                shell_p.append(m)
        K_shell_p[ks]=shell_p
    #print('K_shell_a:',K_shell_a)
    #print('K_shell_p:',K_shell_p)
    return(K_shell_a,K_shell_p)

#Add property 'ks' (kshell) to the Graph (G)    
def G_shell(G, K_shell_a, K_shell_p):
    for ks in K_shell_a:
        list_a = K_shell_a[ks]
        for s in list_a:
            G.node[s]['ks']=ks
    for ks in K_shell_p:
        list_a = K_shell_p[ks]
        for s in list_a:
            G.node[s]['ks']=ks
    return(G)

#Add property 'kskcore' to the graph (G): number of neighbors in the core    
def G_add_kskcore(G, ksmax):
    for nodo in G.node:
        ksmax_vecinos = 0
        for nodo2 in G.edge[nodo]:
            if G.node[nodo2]['ks'] == ksmax:
                ksmax_vecinos += 1
        G.node[nodo]['kskcore']= ksmax_vecinos
    return(G)
   
#Add property 'ksks' to the grpah G
def G_add_ksks(G, ksmax):
    for nodo in G.node:
        ksmax_vecinos = 0
        for nodo2 in G.edge[nodo]:
            if G.node[nodo2]['ks'] >= G.node[nodo]['ks']: # conectado a vecino de Kshell>=suyo
                ksmax_vecinos += 1
        G.node[nodo]['ksks']= ksmax_vecinos
    return(G)
    
#Obtain Giant component  : G2
def Giant_component(G):
    subgraphs =  nx.connected_component_subgraphs(G, copy=True)
    G2 = nx.Graph()
    ls=0
    list_graph=[]
    list_len=[]
    for s in subgraphs:
        list_graph.append(s)
        list_len.append(len(s.nodes()))
    maxlen=np.max(list_len)
    imax=list_len.index(maxlen)
    G2 = list_graph[imax].copy()
    return(G2)
    
def extinct_MM_diam_row(MM, G2, row_order = [], col_order = [] ):
    M2=cp.deepcopy(MM)

    sec_extinct ={}
    diam_extinct = {}
    if (len(row_order) == 0):
        row_order = [np.arange(M2.shape[0])]
        col_order = [np.arange(M2.shape[1])]

    animal_extinct = []
    an_extinct = []
    plant_extinct = []
    quedaenGC = []
    setplant = {}    
    
    for i in range(M2.shape[0]):
        M2[i,:]=0 #index=0, remove rows
        cols_zero=[]
        pl_extinct = []
        an_extinct.append("animal "+str(row_order[0][i]+1))
        for m in range(M2.shape[1]):
            if (not M2[:,m].any()):
                cols_zero.append(m)
#                print(col_order[m])
                pl_extinct.append("plant "+str(col_order[0][m]+1))
        sec_extinct[i] = cols_zero
        animal_extinct.append(an_extinct)
        if (i == 0):
            plant_extinct.append(pl_extinct)
            setplant = set(pl_extinct)
        else:
            plant_extinct.append(list(set(pl_extinct)-setplant))
            setplant = setplant.union(set(pl_extinct))
        G = M_graph(M2)
        G2 = Giant_component(G)
        #print('Gigante: ',G2.nodes())
        quedaenGC.append(len(G2))
        if (dunnemethod):
            diam_extinct[i] = M2.shape[1]-len(sec_extinct[i])
        else:
            diam_extinct[i] = quedaenGC[i]
        
    return(sec_extinct, diam_extinct, animal_extinct, plant_extinct,quedaenGC)

def read_file_csv_2part(filename, nrows, ncols, dtype_in=int): #OJO el archivo _ANALYSIS 1ª columnas,2ª filas
  
    archivo = open(filename,'r')
    lista = archivo.read()
    listas = lista.splitlines()
    Lista = [line.split(',') for line in listas]
    
    Lista.pop(0)
    MM_row = np.zeros((nrows,1), dtype=[('Krad','double'), ('Kdegree','double'),\
                      ('Kshell','double'), ('Krisk','double'),('Degree','double'),\
                      ('eigenc','double')])
    MM_col = np.zeros((ncols,1), dtype=[('Krad','double'), ('Kdegree','double'),\
                      ('Kshell','double'), ('Krisk','double'),('Degree','double'),\
                      ('eigenc','double')]) 

    if Lista[-1] == '':
        Lista.pop(-1)
        
    for c in range(ncols):
        col = Lista[c]
        col.pop(0)
        MM_col[c]= (col[0], col[1], col[2], col[3], col[4], col[5])

    for r in range(nrows):
        row = Lista[r+ncols]
        row.pop(0)
        MM_row[r]= (row[0], row[1], row[2], row[3], row[4], row[5])
          
    MM_row['Kdegree'] = -MM_row['Kdegree']  # 'Krad' es MENOR para los MAS importantes y 'Kdeg' al revés.
    MM_col['Kdegree'] = -MM_col['Kdegree']  # 'Krad' es MENOR para los MAS importantes y 'Kdeg' al revés.
    MM_row['Krisk'] = -MM_row['Krisk']
    MM_col['Krisk'] = -MM_col['Krisk']
    MM_row['Degree'] = -MM_row['Degree']
    MM_col['Degree'] = -MM_col['Degree']
    MM_row['eigenc'] = -MM_row['eigenc']
    MM_col['eigenc'] = -MM_col['eigenc']
    
    return(MM_row, MM_col)

def sort_method(MM_row, MM_col,M, method):
    
    MM_rowT = MM_row.T
    MM_colT = MM_col.T

    method_sort_row = np.array(np.argsort(MM_rowT, order=[method]))
    method_sort_col = np.array(np.argsort(MM_colT, order=[method]))
    
    nrows=method_sort_row.shape[1]
    ncols=method_sort_col.shape[1]
    MM=np.zeros((nrows,ncols))
    for i in range(nrows):
        for j in range(ncols):
            MM[i][j]=M[method_sort_row[0][i]][method_sort_col[0][j]]
    return(method_sort_row, method_sort_col, MM)
    
def sort_method_double(MM_row, MM_col,M, method1, method2):
    
    MM_rowT = MM_row.T
    MM_colT = MM_col.T

    method_sort_row = np.array(np.argsort(MM_rowT, order=[method1,method2]))
    method_sort_col = np.array(np.argsort(MM_colT, order=[method1,method2]))
    
    nrows=method_sort_row.shape[1]
    ncols=method_sort_col.shape[1]
    MM=np.zeros((nrows,ncols))
    for i in range(nrows):
        for j in range(ncols):
            MM[i][j]=M[method_sort_row[0][i]][method_sort_col[0][j]]
    return(method_sort_row, method_sort_col, MM)

def sort_Krisk(MM_row, MM_col,M):
    
    MM_rowT = MM_row.T
    MM_colT = MM_col.T

    Krisk_sort_row = np.array(np.argsort(MM_rowT, order=['Krisk']))
    Krisk_sort_col = np.array(np.argsort(MM_colT, order=['Krisk']))
    
    nrows=Krisk_sort_row.shape[1]
    ncols=Krisk_sort_col.shape[1]
    MM=np.zeros((nrows,ncols))
    for i in range(nrows):
        for j in range(ncols):
            MM[i][j]=M[Krisk_sort_row[0][i]][Krisk_sort_col[0][j]]
    return(Krisk_sort_row, Krisk_sort_col, MM)
   
#Sort MM_row and MM_col    
def sort_Krad_Kdeg(MM_row, MM_col,M):
    
    MM_rowT = MM_row.T
    MM_colT = MM_col.T
    Krad_sort_row = np.array(np.argsort(MM_rowT, order=['Krad','Kdegree']))
    Krad_sort_col = np.array(np.argsort(MM_colT, order=['Krad','Kdegree']))
    
    nrows=Krad_sort_row.shape[1]
    ncols=Krad_sort_col.shape[1]
    MM=np.zeros((nrows,ncols)) #Matrix M reorded following 'Krad + Kdeg'
    for i in range(nrows):
        for j in range(ncols):
            MM[i][j]=M[Krad_sort_row[0][i]][Krad_sort_col[0][j]]
    return(Krad_sort_row, Krad_sort_col, MM)
    
#Sort rows and columns according to 1.-Kshell 2.-Krad  3.-Kdeg   
def sort_Kshell_Krad_Kdeg(MM_row, MM_col, M, G, K_shell_a, K_shell_p):

    Krad_sort_row = []  
    Krad_sort_col = []  
    ksmax=max([ks for ks in K_shell_a])
        
    for ks_a in range(ksmax,0,-1):
        MM_row_shell = MM_row[K_shell_a[ks_a]]
        MM_row_shellT = MM_row_shell.T   # 'argsort' works with rows
        index_sort_row = np.array(np.argsort(MM_row_shellT, order=['Krad','Kdegree']))
        
        for nod in range(len(K_shell_a[ks_a])):
            Krad_sort_row.append(K_shell_a[ks_a][index_sort_row[0][nod]])           

        NNa = offset_plants
        K_shell_p0 = [i - NNa for i in K_shell_p[ks_a]]
        MM_col_shell = MM_col[K_shell_p0]
        MM_col_shellT = MM_col_shell.T   # hay que trasponer porque trabaja sobre filas
        index_sort_col = np.array(np.argsort(MM_col_shellT, order=['Krad','Kdegree']))
        
        for nod in range(len(K_shell_p[ks_a])):
            Krad_sort_col.append(K_shell_p0[index_sort_col[0][nod]])
                   
    nrows=M.shape[0]
    ncols=M.shape[1]
    MM=np.zeros((nrows,ncols))  #Matrix  M ordered by Kshell+Krad+Kdeg
    for i in range(nrows):
        for j in range(ncols):
            MM[i][j]=M[Krad_sort_row[i]][Krad_sort_col[j]]
    return(Krad_sort_row, Krad_sort_col, MM)
    
    
#Algorithn MusRank    
def MusRank(M):
    nrows=M.shape[0]
    ncols=M.shape[1]
    I_a_m=np.ones([nrows,1])
    I_a_m += 0.1
    V_p_m=np.ones([1,ncols])
    V_p_m += 0.1
    n=0
    error = 1.0
    while (np.max(np.abs(error)) > 0.05) and (n<50):
        I_a_i=np.dot(M,V_p_m.reshape(ncols,1))
        Imed=np.mean(I_a_i)
        if Imed !=0:
            I_a_n=np.array(I_a_i/Imed)
        else:
            print('ERROR, Imed=0')
        if I_a_m.any() == 0:
            print('ERROR: I_a_m ==0')
            break
        I_a_inv=np.array(1.0/(I_a_m))
        V_p_j=np.dot((I_a_inv.reshape(1,nrows)),M)
        #print(V_p_j)
        if V_p_j.any() == 0:
            print('ERROR, V_p_j=0')
        else:
            V_p_inv=np.array(1.0/(V_p_j))

        Vmed=np.mean(V_p_inv)
        V_p_n=V_p_inv/Vmed
        
        if I_a_m.any() == 0:
            print('ERROR: I_a_m=0')
        if V_p_m.any() == 0:
            print('ERROR: V_p_m=0')
        
        error_I = (I_a_m - I_a_n)/I_a_m
        error_V = (V_p_m - V_p_n)/V_p_m
        error = error_I

        #print(I_a_n)
        I_a_m=I_a_n
        V_p_m=V_p_n
        n +=1
    print('converge en: ',n, ' pasos')
    #print('Ian:',I_a_n)
    #print('Vpn:',V_p_n)
    return(I_a_n, V_p_n)

#Sort animals and plants by I_a_ & V_p_n    
def sort_MusRank(I_a_n, V_p_n, M):
    nrows=M.shape[0]
    ncols=M.shape[1]
    index_list=np.argsort(I_a_n,axis=0)
    I_sorted=np.flipud(index_list)
    index_list=np.argsort(V_p_n,axis=1)
    V_sorted=index_list
    MM=np.zeros([nrows,ncols])
    for i in range(nrows):
        for j in range(ncols):
            MM[i][j]=M[I_sorted[i][0]][V_sorted[0][j]]
    MR=np.zeros((nrows+ncols,2))
    for i in range(nrows):
        MR[i][0] = i
        MR[i][1] = I_a_n[i][0]
    for j in range(ncols):
        k = j + offset_plants
        MR[j+nrows][0]=k
        MR[j+nrows][1]=V_p_n[0][j]
    p = I_sorted.tolist()
    row_ord = [[x[0] for x in p ]]
    col_ord = V_sorted.tolist()
    return(MM,MR,row_ord,col_ord)

#Graph with nodes:kshell_a&kshell_p; links: links between K_shells    
def K_graph (K_shell_a, K_shell_p, M):
    K_grafo = nx.Graph()
    (Na,Np) = shape(M)
    NNa = offset_plants
    NKs_a = 100  #ID for Kshell_animal = i-shell+100

    for ks_a in K_shell_a:
        K_grafo.add_node(ks_a,bipartite=1)
        for ks_p in K_shell_p:
            ks_p_grafo = ks_p + NKs_a
            K_grafo.add_node(ks_p_grafo,bipartite=0)
            for a in K_shell_a[ks_a]:
                for p in K_shell_p[ks_p]:
                    p_R = p - NNa
                    if M[a][p_R]>0:
                        if ((ks_a,ks_p_grafo) not in K_grafo.edges()) and ((ks_p_grafo,ks_a) not in K_grafo.edges()):
                            K_grafo.add_edge(ks_a,ks_p_grafo,weight=1)
                        else:
                            w=K_grafo[ks_a][ks_p_grafo]['weight']
                            w +=1
                            K_grafo[ks_a][ks_p_grafo]['weight']=w
                            #print(a)
    print(K_grafo.edges(data=True)) 
    return(K_grafo)

#Matrix MM between kshell_a & Kshell_p
def Kshell_matrix (K_shell_a, K_shell_p,K_grafo):
    ks_max=max(max(K_shell_a),max(K_shell_p))
    print('ksmax = ',ks_max)
    KM=np.zeros((ks_max,ks_max))
    NKs_a = 100
    for ks_a in K_shell_a:
        for ks_p in K_shell_p:
            ks_p_grafo = ks_p + NKs_a
            if ((ks_a,ks_p_grafo) in K_grafo.edges()) or ((ks_p_grafo,ks_a) in K_grafo.edges()):
                KM[ks_a - 1][ks_p - 1]=K_grafo[ks_a][ks_p_grafo]['weight']
    return(KM)

def write_deads(dead_animals,dead_plants,qGC,metodo,file_root,strf):
    trail = '_DeadSequence_extin_'+metodo+'_'+strf+'.txt'
    fileoutd = gen_file_out(file_root,strf, trail )
    array_dead_extin = []  
    for i in range(len(dead_animals)):
        array_dead_extin.append(str(dead_animals[-1][i])+' '+\
                        str.replace(str(dead_plants[i]),"'","")+" GC:"+str(qGC[i]))
    np.savetxt(fileoutd,array_dead_extin, fmt='%s', newline = "\r\n")
    
def write_results(prim_extin_frac,diam_extin_frac,metodo,file_root,strf):   
    fileout = gen_file_out(file_root,strf,'_Diam_extin_'+metodo+'.txt')
    array_diam_extin = np.zeros((len(prim_extin_frac),2))
    for i in range(len(prim_extin_frac)):
        array_diam_extin[i] = np.array([[prim_extin_frac[i], diam_extin_frac[i]]])
    np.savetxt(fileout,array_diam_extin, fmt='%-7.4f', newline = "\r\n")
    
#plot imshow and save: matrix KM    
def plot_save_KM(KM,ks_max,filename):

    x=np.arange(0,ks_max,1)
    y=np.arange(0,ks_max,1)
    X,Y=np.meshgrid(x,y)
    KM_max=np.max(KM)
    plt.imshow(KM,interpolation='none',cmap=cm.jet,extent=[0,ks_max,ks_max,0],vmax=KM_max, vmin=0)
    plt.colorbar()
    fig1=plt.gcf()
    plt.show()
    
    file2=filename[0:-4]
    fileout = gen_file_out(file2,strf,'_KM.txt')
    
    print("fileout:"+fileout)    
    
    np.savetxt(fileout,KM, fmt='%-7.2f', newline = "\r\n")
    
    fileout = gen_file_out(file2,strf,'_KM.jpg')
    fig1.savefig(fileout, bbox_inches='tight')
    return()

def calc_frac_extinct(metodo_sort_row, metodo_sort_col, MMmetodo, G, ncols, nrows):

    plt.imshow(MMmetodo,interpolation='none',cmap=cm.RdYlGn,extent=[0,ncols,0,nrows],vmax=1, vmin=0)
    show()
    (sec_extin_metodo, diam_extin_metodo, dead_animals, dead_plants, qGC) = \
                 extinct_MM_diam_row(MMmetodo,G, row_order = metodo_sort_row, col_order = metodo_sort_col)
    sec_extin_metodo_fr=[]
    for i in sec_extin_metodo:
        sec_extin_metodo_fr.append(len(sec_extin_metodo[i])/ncols)
        sec_extin_metodo_frac=np.array(sec_extin_metodo_fr)
    sec_extin_metodo_frac = np.insert(sec_extin_metodo_frac,0,0)  
    prim_extin=np.array(range(nrows+1))
    prim_extin_frac=prim_extin/(nrows)
    diam_extin_metodo_frac=[]
    for i in diam_extin_metodo:
        diam_extin_metodo_frac.append(diam_extin_metodo[i]/diam_extin_metodo[0])
    diam_extin_metodo_frac.append(0)
    area_metodo= np.trapz(diam_extin_metodo_frac, prim_extin_frac)
    figure, hold(True)
    plt.plot(prim_extin, diam_extin_metodo_frac)
    show()

    return(area_metodo, prim_extin_frac, diam_extin_metodo_frac, dead_animals, dead_plants, qGC)

def process_method(MM_row, MM_col,M,method,G,ncols,nrows,file_root,strf):
    print('Now by '+method)
    [method_sort_row, method_sort_col, MMmethod]=sort_method(MM_row, MM_col,M,method)
    area_method, prim_extin_frac,diam_extin_method_frac,dead_animals, dead_plants, qGC = \
         calc_frac_extinct(method_sort_row, method_sort_col, MMmethod, G, ncols, nrows)
    print('area diam_extin_MM'+method+' = ',area_method)
    write_results(prim_extin_frac,diam_extin_method_frac,method,file_root,strf)   
    write_deads(dead_animals,dead_plants,qGC,method,file_root,strf)
    return(area_method)

def process_method_double(MM_row, MM_col,M,method1,method2,G,ncols,nrows,file_root,strf):
    print('Now by '+method1+method2)
    [method_sort_row, method_sort_col, MMmethod]=sort_method_double(MM_row, MM_col,M,method1,method2)
    area_method, prim_extin_frac,diam_extin_method_frac,dead_animals, dead_plants, qGC = \
         calc_frac_extinct(method_sort_row, method_sort_col, MMmethod, G, ncols, nrows)
    print('area diam_extin_MM'+method1+method2+' = ',area_method)
    write_results(prim_extin_frac,diam_extin_method_frac,method1+method2,file_root,strf)   
    write_deads(dead_animals,dead_plants,qGC,method1+method2,file_root,strf)
    return(area_method)
      
#Main function for each file: filename    
def Diam_extin_KshKrad_MusRank(filename):
    M = read_file_csv(filename)
    file_root=filename[0:-4]
    filein2=(file_root+'_analysis.csv').replace("data","analysis_indiv_extended")

    print("file_root",file_root)
    print("filein2",filein2)    
    
    NNa = offset_plants
    nrows = M.shape[0]
    ncols = M.shape[1]
    G = M_graph(M)
    Kcore = K_core_graph(G)
    (K_shell_a, K_shell_p) = K_shell(Kcore,M.shape[0], M.shape[1])
    G_shell(G, K_shell_a, K_shell_p)
    ksmax = np.max([ks for ks in K_shell_a])
    print('ksmax= ', ksmax)
    G_add_kskcore(G,ksmax)
    G_add_ksks(G, ksmax)
    G2 = Giant_component(G)
    diam_extin_ini=len(G2)

    (sec_extin_NoOrder, diam_extin_NoOrder, dead_animals, dead_plants, qGC) = \
                                                       extinct_MM_diam_row(M,G)
    sec_extin_NoOrder_fr=[]
    for i in sec_extin_NoOrder:
        sec_extin_NoOrder_fr.append(len(sec_extin_NoOrder[i])/ncols)
        sec_extin_NoOrder_frac=np.array(sec_extin_NoOrder_fr)
    sec_extin_NoOrder_frac = np.insert(sec_extin_NoOrder_frac,0,0)
    
    prim_extin=np.array(range(nrows+1))
    prim_extin_frac=prim_extin/(nrows)
    diam_extin_NoOrder_frac=[]
    for i in diam_extin_NoOrder:
        diam_extin_NoOrder_frac.append(diam_extin_NoOrder[i]/diam_extin_NoOrder[0])
    diam_extin_NoOrder_frac.append(0)

    area_NoOrder= np.trapz(diam_extin_NoOrder_frac, prim_extin_frac)
    print('area diam_extin_MMNoOrder = ',area_NoOrder)

    figure, hold(True)
    plt.plot(prim_extin_frac, diam_extin_NoOrder_frac)
    show()
    
    fileout = gen_file_out(file_root,strf,'_Diam_extin_NoOrder.txt')
    array_diam_extin_NoOrder = np.zeros((len(prim_extin_frac),2))
    for i in range(len(prim_extin_frac)):
        array_diam_extin_NoOrder[i] = np.array([[prim_extin_frac[i], diam_extin_NoOrder_frac[i]]])

    np.savetxt(fileout,array_diam_extin_NoOrder, fmt='%-7.4f', newline = "\r\n")
   
    [MM_row, MM_col] = read_file_csv_2part(filein2,nrows,ncols,double)

    area_KriskKdegree =  process_method_double(MM_row, MM_col,M,'Krisk','Kdegree',G,ncols,nrows,file_root,strf)
    area_Krisk = process_method(MM_row, MM_col,M,'Krisk',G,ncols,nrows,file_root,strf)
    area_Krad = process_method(MM_row, MM_col,M,'Krad',G,ncols,nrows,file_root,strf)
    area_Kdegree = process_method(MM_row, MM_col,M,'Kdegree',G,ncols,nrows,file_root,strf)
    area_Degree = process_method(MM_row, MM_col,M,'Degree',G,ncols,nrows,file_root,strf)
    area_eigenc = process_method(MM_row, MM_col,M,'eigenc',G,ncols,nrows,file_root,strf)

    
    ###############################
    ### Order by Kshell + Krad + Kdeg

    print('Now order by Kshell + Krad + Kdeg')
    
    [KshKrad_sort_row, KshKrad_sort_col, MM_KshKrad]=sort_Kshell_Krad_Kdeg(MM_row, MM_col,M, G, K_shell_a, K_shell_p)
    #print('MM_KshKrad.shape:',MM_KshKrad.shape)
    plt.imshow(MM_KshKrad,interpolation='none',cmap=cm.RdYlGn,extent=[0,ncols,0,nrows],vmax=1, vmin=0)
    show()

    [sec_extin_KshKrad, diam_extin_KshKrad, dead_animals, dead_plants, qGC]= \
        extinct_MM_diam_row(MM_KshKrad,G,row_order = [KshKrad_sort_row], col_order = [KshKrad_sort_col])
    sec_extin_KshKrad_fr=[]
    for i in sec_extin_KshKrad:
        sec_extin_KshKrad_fr.append(len(sec_extin_KshKrad[i])/ncols)
        sec_extin_KshKrad_frac=np.array(sec_extin_KshKrad_fr)
    sec_extin_KshKrad_frac = np.insert(sec_extin_KshKrad_frac,0,0)
    
    prim_extin=np.array(range(nrows+1))
    prim_extin_frac=prim_extin/(nrows)
    diam_extin_KshKrad_frac=[]
    for i in diam_extin_KshKrad:
        diam_extin_KshKrad_frac.append(diam_extin_KshKrad[i]/diam_extin_KshKrad[0])
    diam_extin_KshKrad_frac.append(0)

    area_KshKrad= np.trapz(diam_extin_KshKrad_frac, prim_extin_frac)
    print('area diam_extin_MM_KshKrad = ',area_KshKrad)

    figure, hold(True)
    plt.plot(prim_extin_frac, diam_extin_KshKrad_frac)
    show()
        
    fileout = gen_file_out(file_root,strf,'_Diam_extin_KshKrad.txt')
    array_diam_extin_KshKrad = np.zeros((len(prim_extin_frac),2))
    for i in range(len(prim_extin_frac)):
        array_diam_extin_KshKrad[i] = np.array([[prim_extin_frac[i], diam_extin_KshKrad_frac[i]]])

    np.savetxt(fileout,array_diam_extin_KshKrad, fmt='%-7.4f', newline = "\r\n")
    
    write_deads(dead_animals,dead_plants,qGC,"KshKrad",file_root,strf)

    
    ##### MusRank
    print('Now by MusRank')
    (I_a_n, V_p_n) = MusRank(M)
    (MM_MR,MR, row_mus, col_mus) = sort_MusRank(I_a_n, V_p_n, M)
  
#    print(MM_MR)
#    print(MR)
    
    fig = plt.imshow(MM_MR,interpolation='none',cmap=cm.RdYlGn,extent=[0,ncols,0,nrows],vmax=1, vmin=0)
    plt.show(fig)
    [secon_extin_MR, diam_extin_MR,dead_animals, dead_plants, qGC] = \
                                 extinct_MM_diam_row(MM_MR,G,row_order = row_mus, col_order = col_mus)
    sec_extin_MR_fr=[]
    for i in secon_extin_MR:
        sec_extin_MR_fr.append(len(secon_extin_MR[i])/ncols)
        sec_extin_MR_frac=np.array(sec_extin_MR_fr)
    sec_extin_MR_frac = np.insert(sec_extin_MR_frac,0,0)

    diam_extin_MR_frac=[]
    for i in diam_extin_MR:
        diam_extin_MR_frac.append(diam_extin_MR[i]/diam_extin_MR[0])
    diam_extin_MR_frac.append(0)
    
    area_MR= np.trapz(diam_extin_MR_frac, prim_extin_frac)
    print('area diam_extin_MR = ',area_MR)

    figure, hold(True)
    plt.plot(prim_extin_frac, diam_extin_MR_frac)
    show()
    
    fileout = gen_file_out(file_root,strf,'_Diam_extin_MusRank.txt')
    array_diam_extin_MR = np.zeros((len(prim_extin_frac),2))
    for i in range(len(prim_extin_frac)):
        array_diam_extin_MR[i] = np.array([[prim_extin_frac[i], diam_extin_MR_frac[i]]])
    np.savetxt(fileout,array_diam_extin_MR, fmt='%-7.4f', newline = "\r\n")
    
    write_deads(dead_animals,dead_plants,qGC,"MusRank",file_root,strf)

###  Plot KM_graph 
    K_grafo=K_graph(K_shell_a,K_shell_p,M)
    KM=Kshell_matrix(K_shell_a,K_shell_p,K_grafo)
    ks_max=max(max(K_shell_a),max(K_shell_p))
    plot_save_KM(KM,ks_max,filename)
    
    return(area_NoOrder, area_Krad, area_KshKrad, area_MR, area_Krisk, 
           area_KriskKdegree, area_Kdegree, area_Degree, area_eigenc)

    
#################################
### MAIN

# if alldir True all files are processed
alldir = True
# if dunnemethod only fraction of extinct plants is computed, else fraction
# of Giant Component
dunnemethod = False

offset_plants = 10000

if dunnemethod:
    strf = "dunnemethod"
else:
    strf = "juanmamethod"

if (alldir):   
    #filenames = glob.glob('weblife\M_??_0??.csv') 
    filenames = glob.glob('..\\data\\M_??_0??.csv')
else:
    #filenames = list(['weblife\\M_PL_003.csv'])    
    filenames = list(['..\\data\\M_PL_003.csv'])
numfiles = size(filenames)
Diam_extin_file = np.zeros((numfiles,9))
n=0
for filename in filenames[0:numfiles]:  
    filename = filename.replace('\\', '/')
    print(filename)
    [area_NoOrder, area_Krad, area_KshKrad, area_MR, area_Krisk, 
     area_KriskKdegree, area_Kdegree, area_Degree, area_eigenc] =  \
                    Diam_extin_KshKrad_MusRank(filename)  #Programa principal
    Diam_extin_file[n,:]=np.array(( area_NoOrder, area_Krad, area_KshKrad, 
                                    area_MR, area_Krisk, area_KriskKdegree, 
                                    area_Kdegree, area_Degree, area_eigenc))
    n += 1
    
print("Game over!!!")
file2=filename[0:-4]
print("file 2"+file2)
#fileout=file2+'_Diam_extin_all.txt'    
if (alldir):
    fileout = "results\\"+strf+"\\DIAM_EXTIN_ALL_"+strf+".txt"
else:
    fileout = "results\\"+strf+"\\DIAM_EXTIN_PARTIAL.txt"
print("file out: "+fileout)
np.savetxt(fileout,(Diam_extin_file),fmt='%-7.3f', newline = "\r\n")
#print('Diam_extin_all_file: ', Diam_extin_file)
