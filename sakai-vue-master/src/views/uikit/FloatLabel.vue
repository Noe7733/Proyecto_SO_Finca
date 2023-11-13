<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();
</script>

<script>
import axios from 'axios';
import { ref } from 'vue';

const productDialog = ref(false);
const productDialogAct = ref(false);

//Constantes las cuales sirven para obtener los datos de las ventanas modales en la operación actualización de datos 
const modal = ref(false);
const numberT = ref(false);
const capacidad = ref(false);


const openWindow = () => {
    productDialog.value = true;
};
const openWindowAct = (row) => {
    numberT.value = row.numtanque;
    modal.value = row.modelo;
    capacidad.value = row.maxkgt;

    productDialogAct.value = true;
};
export default {
    data() {
        return {
            tanques: null,
            numTT: numberT,
            modeloo: modal,
            kgMaximoss: capacidad,
        }
    },
    mounted() {
        this.listarTablaT();
    },
    methods: {
        async realizarSolicitudT() {
            if (this.numT == null && this.modelo == null && this.kgMaximos == null) { //validación del campo nulo
                this.$toast.add({ severity: 'warn', summary: '¡Favor de ingresar los datos!', detail: '¡Ingresar los datos requeridos!', life: 5000 });
            } else {
                try {
                    const response = await axios.post('http://localhost:3000/postTanque', { //llamada a la REST API
                        numtanque: this.numT,
                        modelo: this.modelo,
                        maxkgt: this.kgMaximos // Usar el nombre del terreno ingresado por el usuario
                    });
                    console.log('Respuesta:', response.data);
                    this.$toast.add({ severity: 'success', summary: 'Tanque ingresado de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                } catch (error) {
                    console.error('Error al hacer la solicitud POST:', error);
                    this.$toast.add({ severity: 'warn', summary: 'El tanque deseado no se ha podido registrar :( )', detail: '¡Probleas internos!', life: 5000 });
                }
            }
            //método con el cual se realiza la recarga de la pagina
            setTimeout(() => {
                location.reload();
            }, 2000); //dos segundos convertidos en milisegundos
        },
        async listarTablaT() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/getTanques',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.tanques = JSON.parse(response.data);
                    console.log(this.tanques);
                });
        },
        async deleteTanque(row) {
            try {
                const response = await axios.delete(`http://localhost:3000/deleteTanque/${row.idtanque}`);
                this.$toast.add({ severity: 'success', summary: 'Tanque eliminado de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log(response);
            } catch (error) {
                console.error('Error al hacer la solicitud DELETE:', error);
                this.$toast.add({ severity: 'warn', summary: 'El tanque deseado no se ha podido eliminar :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        }
    }
};

</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <div class="card">
                    <h3>Sección de tanques</h3>
                    <Toast />
                    <Toolbar class="mb-4">
                        <template v-slot:start>
                            <div class="my-2">
                                <Button label="Agregar Tanque" icon="pi pi-plus" class="p-button-success mr-2"
                                    @click="openWindow" />
                            </div>
                        </template>
                        <template v-slot:end>
                            <span class="p-input-icon-left mb-2">
                                <i class="pi pi-search" />
                                <InputText placeholder="Codigo de fermentación" style="width: 100%" />
                            </span>
                        </template>
                    </Toolbar>
                    <!--TABLA DE TANQUES-->
                    <DataTable v-bind="value" :value="tanques" class="p-datatable-gridlines" :paginator="true" :rows="10"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} tanque(s)."
                        responsiveLayout="scroll">
                        <Column field="idtanque" header="Codigo del tanque" :sortable="true" style="width:50px"></Column>
                        <Column field="numtanque" header="Número de tanque" style="width:100px"></Column>
                        <Column field="modelo" header="Modelo" style="width:120px"></Column>
                        <Column field="maxkgt" header="Capacidad maxima" style="width:120px"></Column>
                        <Column field="statust" header="Status" style="width:170px"></Column>
                        <Column style="width:180px">
                            <template #header>
                                Acciones
                            </template>
                            <template #body="slotProps">
                                <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1"
                                    @click="openWindowAct(slotProps.data)"></Button>
                                <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1"
                                    @click="deleteTanque(slotProps.data)"></Button>
                            </template>
                        </Column>
                    </DataTable>
                </div>
                <!--TABLA DE FERMETACION-->
                <div class="card">
                    <h3>Sección de tanques</h3>
                    <Toast />
                    <Toolbar class="mb-4">
                        <template v-slot:start>
                            <div class="my-2">
                                <Button label="Agregar Tanque" icon="pi pi-plus" class="p-button-success mr-2"
                                    @click="openWindow" />
                            </div>
                        </template>
                        <template v-slot:end>
                            <span class="p-input-icon-left mb-2">
                                <i class="pi pi-search" />
                                <InputText placeholder="Codigo de fermentación" style="width: 100%" />
                            </span>
                        </template>
                    </Toolbar>
                    <DataTable v-bind="value" :value="fermentacion" class="p-datatable-gridlines" :paginator="true"
                        :rows="10"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} lotes a fermentar."
                        responsiveLayout="scroll">
                        <Column field="idfermetacion" header="Codigo de fermentación" :sortable="true" style="width:50px">
                        </Column>
                        <Column field="iddespulpado" header="Codigo de despulpado" style="width:100px"></Column>
                        <Column field="idtanque" header="Codigo de tanque" style="width:120px"></Column>
                        <Column field="tempmin" header="Tem. minima" style="width:120px"></Column>
                        <Column field="tempmax" header="Tem. maxima" style="width:120px"></Column>
                        <Column field="tiempof" header="Hora" style="width:120px"></Column>
                        <Column field="statust" header="Status" style="width:170px"></Column>
                        <Column style="width:180px">
                            <template #header>
                                Acciones
                            </template>
                            <template #body="slotProps">
                                <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1"
                                    @click="openWindowAct(slotProps.data)"></Button>
                                <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1"
                                    @click="deleteTanque(slotProps.data)"></Button>
                            </template>
                        </Column>
                    </DataTable>
                </div>
                <!-- VENTANA MODAL PARA EL INGRESO DE UN TANQUE-->
                <Dialog v-model:visible="productDialog" :style="{ width: '500px' }"
                    header="Registrar el nuevo tanque de café" modal="true" class="p-fluid">
                    <div class="field">
                        <label for="name">Número de tanque: </label>
                        <InputText id="numtanque" v-model="numT" />
                        <hr>
                        <label for="name">Modelo del tanque: </label>
                        <InputText id="modelT" v-model="modelo" />
                        <hr>
                        <label for="name">Capacidad en gramos del tanque: </label>
                        <InputText id="kgMax" v-model="kgMaximos" />
                        <hr>
                        <Button label="Ingresar" class="p-button-raised p-button-success mr-2 mb-2"
                            @click="realizarSolicitudT"></Button>
                    </div>
                </Dialog>
                <!-- VENTANA MODAL PARA LA ACTUALIZACIÓN DE UN TANQUE-->
                <Dialog v-model:visible="productDialogAct" :style="{ width: '500px' }"
                    header="Registrar el nuevo tanque de café" modal="true" class="p-fluid">
                    <div class="field">
                        <label for="name">Número de tanque: </label>
                        <InputText id="numTanque" v-model="numTT" />
                        <hr>
                        <label for="name">Modelo del tanque: </label>
                        <InputText id="modelT" v-model="modeloo" />
                        <hr>
                        <label for="name">Capacidad en gramos del tanque: </label>
                        <InputText id="kgMax" v-model="kgMaximoss" />
                        <hr>
                        <Button label="Ingresar" class="p-button-raised p-button-success mr-2 mb-2"
                            @click="realizarSolicitudT"></Button>
                    </div>
                </Dialog>
            </div>
        </div>
    </div>
</template>
