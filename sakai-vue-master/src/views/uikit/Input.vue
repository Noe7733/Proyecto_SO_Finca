<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();
</script>

<script>

import { ref } from 'vue';
import axios from "axios";

const productDialog = ref(false);

const openWindow = () => {
    productDialog.value = true;
};

export default {
    data() {
        return {
            despulpado: null,
            botonInhabilitado: false,
            idrecoleccion:null,
            iddespulpado:null,
        }
    },
    mounted() {

    },
    methods: {
        async getAllDespulpados(){
            axios({
                method: 'POST',
                url: 'http://localhost:3000/tablaPrincDespul',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.despulpado = JSON.parse(response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lotes cargados de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                });
        },
        async viewDataTableDespul(){
            axios({
                method: 'GET',
                url: 'http://localhost:3000/selectDataDespul',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.despulpado = JSON.parse(response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lotes disponibles para despulpar', detail: '¡Todo bien!', life: 5000 });
                    console.log('Respuesta de la ventanaCreateRRRR: ', response.data);
                });
        },
        desactivarBoton() {
            this.botonInhabilitado = true;
        },
        async actFechaHora(row){
            //console.log(this.numlote);
            try {
                const response = await axios.post(`http://localhost:3000/fechaHoraDespulpado`, {
                    iddespulpado: row.iddespulpado,
                    idrecoleccion: row.idrecoleccion,
                });
                this.$toast.add({ severity: 'success', summary: 'Despulpado exitoso', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización btn:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud PUT:', error);
                this.$toast.add({ severity: 'warn', summary: 'Despulpado fallido :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
        async actSts(row){
            try {
                const response = await axios.put(`http://localhost:3000/actStsDespul/${row.iddespulpado}`, {
                });
                this.$toast.add({ severity: 'success', summary: 'Despulpado exitoso', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización btn:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud PUT:', error);
                this.$toast.add({ severity: 'warn', summary: 'Despulpado fallido :( ', detail: '¡Probleas internos!', life: 1000 });
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
                <h3>Despulpado</h3>
                <Toast />
                <Toolbar class="mb-4">
                    <template v-slot:start>
                        <div class="my-2">
                            <Button label="Cargar Lotes" icon="pi pi-plus" class="p-button-raised mr-2" @click="getAllDespulpados() && desactivarBoton()" :disabled="botonInhabilitado" />
                            <Button label="Ver lotes a despulpar" icon="pi pi-plus" class="p-button-success mr-2" @click="viewDataTableDespul()" />
                        </div>
                    </template>
                    <template v-slot:end>
                        <span class="p-input-icon-left mb-2">
                            <i class="pi pi-search" />
                            <InputText placeholder="Codigo de despulpado" style="width: 100%" />
                        </span>
                    </template>
                </Toolbar>

                <DataTable v-bind="value" :value="despulpado" class="p-datatable-gridlines" :paginator="true" :rows="10"
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    :rowsPerPageOptions="[5, 10, 25]"
                    currentPageReportTemplate="Visualiando {last} de {totalRecords} lotes en despulpado"
                    responsiveLayout="scroll">
                    <Column field="iddespulpado" header="Codigo de despulpado" :sortable="true" style="width:50px"></Column>
                    <Column field="idrecoleccion" header="Codigo de recolección" style="width:50px"></Column>
                    <Column field="fecha" header="Fecha" style="width:100px"></Column>
                    <Column field="hora" header="Hora" style="width:120px"></Column>
                    <Column field="statusd" header="Status" style="width:120px"></Column>
                    <Column style="width:180px">
                        <template #header>
                            Acciones
                        </template>
                        <template #body="slotProps">
                            <Button icon="pi pi-plus" type="button" class="p-button-success p-mr-2 p-mb-1" @click="actFechaHora(slotProps.data)"></Button>
                            <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1" @click="actSts(slotProps.data)"></Button>
                        </template>
                    </Column>
                </DataTable>
                <Dialog v-model:visible="productDialog" :style="{ width: '450px' }" header="Proceso de despulpado"
                    :modal="true" class="p-fluid"></Dialog>
            </div>
        </div>
    </div>
</template>
